const fs = require('fs');
const path = require('path');

const sourceFile = path.join(__dirname, 'README.md');
const targetFile = path.join(__dirname, 'public', 'README.md');

// Copy the README.md file
fs.copyFile(sourceFile, targetFile, (err) => {
  if (err) {
    console.error('Error copying README.md:', err);
  } else {
    console.log('README.md copied to public folder.');
  }
});
