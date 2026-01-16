const XLSX = require('xlsx');
const path = require('path');
const fs = require('fs');

// Find the Excel file
const files = fs.readdirSync('.');
const excelFile = files.find(f => f.endsWith('.xlsx') && f.includes('Sahibinden'));
console.log('Found Excel file:', excelFile);

if (!excelFile) {
  console.error('Excel file not found!');
  process.exit(1);
}

const wb = XLSX.readFile(excelFile);
console.log('\n=== SHEETS ===');
console.log(wb.SheetNames);

const ws = wb.Sheets[wb.SheetNames[0]];
const data = XLSX.utils.sheet_to_json(ws, { header: 1 });

console.log('\n=== HEADERS ===');
console.log(data[0]);

console.log('\n=== ROW COUNT ===');
console.log('Total rows:', data.length);

console.log('\n=== SAMPLE ROWS (first 15) ===');
for (let i = 1; i <= 15 && i < data.length; i++) {
  console.log(`Row ${i}:`, data[i]);
}

// Analyze unique values in each column
console.log('\n=== UNIQUE VALUES PER COLUMN ===');
const headers = data[0];
const columnStats = {};

headers.forEach((header, colIndex) => {
  const uniqueValues = new Set();
  for (let i = 1; i < data.length; i++) {
    if (data[i] && data[i][colIndex] !== undefined && data[i][colIndex] !== null && data[i][colIndex] !== '') {
      uniqueValues.add(data[i][colIndex]);
    }
  }
  columnStats[header] = {
    uniqueCount: uniqueValues.size,
    sampleValues: Array.from(uniqueValues).slice(0, 5)
  };
  console.log(`\n${header}:`);
  console.log(`  Unique count: ${uniqueValues.size}`);
  console.log(`  Sample values: ${Array.from(uniqueValues).slice(0, 8).join(', ')}`);
});

// Analyze brand duplicates
console.log('\n=== BRAND ANALYSIS ===');
const brandCol = headers.findIndex(h => h && h.toLowerCase().includes('marka'));
if (brandCol !== -1) {
  const brands = {};
  for (let i = 1; i < data.length; i++) {
    if (data[i] && data[i][brandCol]) {
      const brand = data[i][brandCol].toString().trim();
      brands[brand] = (brands[brand] || 0) + 1;
    }
  }
  
  // Sort by name to see duplicates
  const sortedBrands = Object.keys(brands).sort();
  console.log('\nAll brands (sorted):');
  sortedBrands.forEach(b => {
    console.log(`  ${b}: ${brands[b]} vehicles`);
  });
  
  // Find potential duplicates (similar names)
  console.log('\nPotential duplicates (similar names):');
  const normalized = {};
  sortedBrands.forEach(brand => {
    const key = brand.toLowerCase().replace(/[^a-z0-9]/g, '');
    if (!normalized[key]) normalized[key] = [];
    normalized[key].push(brand);
  });
  
  Object.entries(normalized)
    .filter(([k, v]) => v.length > 1)
    .forEach(([key, values]) => {
      console.log(`  ${key}: ${values.join(' | ')}`);
    });
}
