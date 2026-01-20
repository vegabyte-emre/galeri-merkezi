const XLSX = require('xlsx');
const fs = require('fs');
const path = require('path');

const rootDir = path.join(__dirname, '..');
const files = fs.readdirSync(rootDir).filter(f => f.endsWith('.xlsx'));
const workbook = XLSX.readFile(path.join(rootDir, files[0]));
const sheet = workbook.Sheets[workbook.SheetNames[0]];
const data = XLSX.utils.sheet_to_json(sheet);

console.log('=== TUM SUTUN ISIMLERI ===');
const columns = Object.keys(data[0]);
columns.forEach((col, i) => {
    // Her karakterin ASCII kodunu göster
    const codes = [...col].map(c => c.charCodeAt(0));
    console.log(`${i+1}. "${col}" -> ASCII: [${codes.join(', ')}]`);
});

console.log('');
console.log('=== ILK 5 SATIR DETAYI ===');
data.slice(0, 5).forEach((row, i) => {
    console.log(`Row ${i+1}:`);
    Object.entries(row).forEach(([key, value]) => {
        console.log(`  ${key} = ${value}`);
    });
    console.log('');
});

// Trim sütununu ara
console.log('=== TRIM SUTUNU ARAMA ===');
const trimColumn = columns.find(c => c.toLowerCase().includes('trim'));
if (trimColumn) {
    console.log(`Trim sutunu bulundu: "${trimColumn}"`);
    const trimValues = data.filter(row => row[trimColumn] && row[trimColumn].toString().trim() !== '');
    console.log(`Trim degeri olan satir sayisi: ${trimValues.length}`);
    console.log('Ornek degerler:');
    trimValues.slice(0, 10).forEach((row, i) => {
        console.log(`  ${i+1}. ${row['Marka']} ${row['Model']} - Trim: "${row[trimColumn]}"`);
    });
} else {
    console.log('Trim sutunu bulunamadi!');
}
