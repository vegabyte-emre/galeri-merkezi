const XLSX = require('xlsx');
const fs = require('fs');
const path = require('path');

const rootDir = path.join(__dirname, '..');
const files = fs.readdirSync(rootDir).filter(f => f.endsWith('.xlsx'));
const workbook = XLSX.readFile(path.join(rootDir, files[0]));
const sheet = workbook.Sheets[workbook.SheetNames[0]];
const data = XLSX.utils.sheet_to_json(sheet);

console.log('=== EXCEL COLUMN ANALYSIS ===');
console.log('Columns:', Object.keys(data[0]));
console.log('Total rows:', data.length);

// Trim sütunu var mı kontrol et
const hasTrims = data.filter(row => row['Trim'] && row['Trim'].toString().trim() !== '');
console.log('');
console.log('Rows with Trim:', hasTrims.length);
console.log('Rows without Trim:', data.length - hasTrims.length);

// Trim örnekleri göster
console.log('');
console.log('=== TRIM EXAMPLES (First 20) ===');
hasTrims.slice(0, 20).forEach((row, i) => {
    const marka = row['Marka'] || '';
    const seri = row['Seri'] || '';
    const model = row['Model'] || '';
    const altModel = row['Alt Model'] || '-';
    const trim = row['Trim'] || '';
    const kasaTipi = row['Kasa Tipi'] || '';
    const yakitTipi = row['Yakıt Tipi'] || '';
    const vites = row['Vites'] || '';
    const motorGucu = row['Motor Gücü '] || '';
    const motorHacmi = row['Motor Hacmi'] || '';
    
    console.log(`${i+1}. ${marka} ${seri} ${model}`);
    console.log(`   Alt Model: "${altModel}" | Trim: "${trim}"`);
    console.log(`   Specs: ${kasaTipi} | ${yakitTipi} | ${vites} | ${motorGucu} HP | ${motorHacmi} cc`);
    console.log('');
});

// Alt Model olmadan Trim olanlar
console.log('=== ROWS WITH TRIM BUT NO ALT MODEL ===');
const trimNoAltModel = data.filter(row => {
    const hasAltModel = row['Alt Model'] && row['Alt Model'].toString().trim() !== '';
    const hasTrim = row['Trim'] && row['Trim'].toString().trim() !== '';
    return hasTrim && !hasAltModel;
});
console.log('Count:', trimNoAltModel.length);
trimNoAltModel.slice(0, 10).forEach((row, i) => {
    console.log(`${i+1}. ${row['Marka']} ${row['Seri']} ${row['Model']} | Trim: "${row['Trim']}"`);
});

// Alt Model + Trim kombinasyonları analizi
console.log('');
console.log('=== ALT MODEL + TRIM RELATIONSHIP ===');

// Aynı Alt Model için farklı Trim'ler
const altModelTrims = new Map();
data.forEach(row => {
    const marka = row['Marka'] || '';
    const seri = row['Seri'] || '';
    const model = row['Model'] || '';
    const altModel = row['Alt Model'] ? row['Alt Model'].toString().trim() : '';
    const trim = row['Trim'] ? row['Trim'].toString().trim() : '';
    
    if (altModel) {
        const key = `${marka}|${seri}|${model}|${altModel}`;
        if (!altModelTrims.has(key)) {
            altModelTrims.set(key, { marka, seri, model, altModel, trims: new Set(), specs: [] });
        }
        if (trim) {
            altModelTrims.get(key).trims.add(trim);
        }
        altModelTrims.get(key).specs.push({
            trim,
            kasaTipi: row['Kasa Tipi'] || '',
            yakitTipi: row['Yakıt Tipi'] || '',
            vites: row['Vites'] || '',
            motorGucu: row['Motor Gücü '] || '',
            motorHacmi: row['Motor Hacmi'] || ''
        });
    }
});

// Alt Model'ler için birden fazla Trim olanlar
const multipleTrims = Array.from(altModelTrims.values()).filter(v => v.trims.size > 1);
console.log('Alt Models with multiple trims:', multipleTrims.length);
console.log('');
multipleTrims.slice(0, 10).forEach((v, i) => {
    console.log(`${i+1}. ${v.marka} ${v.seri} ${v.model} - Alt Model: "${v.altModel}"`);
    console.log(`   Trims: ${Array.from(v.trims).join(', ')}`);
    console.log('');
});

// Tek Trim olanlar (veya hiç Trim olmayanlar)
const singleOrNoTrim = Array.from(altModelTrims.values()).filter(v => v.trims.size <= 1);
console.log('Alt Models with single/no trim:', singleOrNoTrim.length);

// Özet
console.log('');
console.log('=== SUMMARY ===');
console.log('Total unique Alt Models:', altModelTrims.size);
console.log('Alt Models with multiple trims (need trim selection):', multipleTrims.length);
console.log('Alt Models with single/no trim (auto-fill specs):', singleOrNoTrim.length);
