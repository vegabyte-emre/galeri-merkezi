// Seed data script
const { query } = require('../../backend/shared/dist/database/connection');

async function seed() {
  // TODO: Add seed data
  console.log('Seed data loaded');
}

seed()
  .then(() => {
    console.log('Seeding completed');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Seeding failed:', error);
    process.exit(1);
  });
















