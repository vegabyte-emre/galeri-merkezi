/**
 * Script to upload brand logos to the catalog
 * 
 * Usage:
 *   node scripts/upload-brand-logos.js <logos-folder-path>
 * 
 * Example:
 *   node scripts/upload-brand-logos.js "C:\Users\Emre\Desktop\otobia\Araç Kataloğu"
 */

const fs = require('fs');
const path = require('path');
const FormData = require('form-data');

const API_URL = process.env.API_URL || 'https://api.otobia.com';
const IMPORT_KEY = process.env.CATALOG_IMPORT_KEY || 'otobia-catalog-import-2026';

async function uploadLogos(folderPath) {
  if (!folderPath) {
    console.error('Usage: node upload-brand-logos.js <logos-folder-path>');
    process.exit(1);
  }

  if (!fs.existsSync(folderPath)) {
    console.error(`Folder not found: ${folderPath}`);
    process.exit(1);
  }

  const files = fs.readdirSync(folderPath).filter(f => 
    f.endsWith('.svg') || f.endsWith('.png') || f.endsWith('.jpg') || f.endsWith('.jpeg')
  );

  console.log(`Found ${files.length} logo files`);

  // First, import brands from the folder (create entries in database)
  const brands = files.map(f => ({
    name: f.replace(/\.[^/.]+$/, ''), // Remove extension
    logo_url: null
  }));

  console.log('\n1. Importing brands to database...');
  
  try {
    const importResponse = await fetch(`${API_URL}/api/v1/catalog/import`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Import-Key': IMPORT_KEY
      },
      body: JSON.stringify({ brands })
    });

    const importResult = await importResponse.json();
    console.log('Import result:', importResult);

    if (!importResult.success) {
      console.error('Failed to import brands:', importResult.message);
      process.exit(1);
    }
  } catch (error) {
    console.error('Import error:', error.message);
    process.exit(1);
  }

  // Now upload logos one by one
  console.log('\n2. Uploading logos...');
  
  let successCount = 0;
  let failCount = 0;

  for (const file of files) {
    const brandName = file.replace(/\.[^/.]+$/, '');
    const filePath = path.join(folderPath, file);
    
    try {
      // Read file
      const fileBuffer = fs.readFileSync(filePath);
      const base64 = fileBuffer.toString('base64');
      const mimeType = file.endsWith('.svg') ? 'image/svg+xml' : 
                       file.endsWith('.png') ? 'image/png' : 'image/jpeg';

      // Find brand ID first
      const brandsResponse = await fetch(`${API_URL}/api/v1/catalog/brands`);
      const brandsData = await brandsResponse.json();
      const brand = brandsData.data?.find(b => 
        b.name.toLowerCase() === brandName.toLowerCase()
      );

      if (!brand) {
        console.log(`  ⚠ Brand not found: ${brandName}`);
        failCount++;
        continue;
      }

      // Create form data
      const FormData = require('form-data');
      const form = new FormData();
      form.append('logo', fileBuffer, {
        filename: file,
        contentType: mimeType
      });

      // Upload logo
      const uploadResponse = await fetch(`${API_URL}/api/v1/catalog/brands/${brand.id}/logo`, {
        method: 'POST',
        headers: form.getHeaders(),
        body: form
      });

      const uploadResult = await uploadResponse.json();

      if (uploadResult.success) {
        console.log(`  ✓ ${brandName}: ${uploadResult.data?.logo_url}`);
        successCount++;
      } else {
        console.log(`  ✗ ${brandName}: ${uploadResult.message}`);
        failCount++;
      }
    } catch (error) {
      console.log(`  ✗ ${brandName}: ${error.message}`);
      failCount++;
    }
  }

  console.log(`\n3. Done!`);
  console.log(`   Success: ${successCount}`);
  console.log(`   Failed: ${failCount}`);
}

// Run
const folderPath = process.argv[2];
uploadLogos(folderPath);
