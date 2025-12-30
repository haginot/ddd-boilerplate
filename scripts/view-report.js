#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const reportDir = path.join(process.cwd(), 'reports');

function latestReport() {
  if (!fs.existsSync(reportDir)) return null;
  const files = fs.readdirSync(reportDir).filter(f => f.endsWith('.json')).sort();
  if (files.length === 0) return null;
  return path.join(reportDir, files[files.length - 1]);
}

const target = process.argv[2] || latestReport();
if (!target || !fs.existsSync(target)) {
  console.error('No report found.');
  process.exit(1);
}

const data = JSON.parse(fs.readFileSync(target, 'utf8'));
console.log(`Report: ${target}`);
console.log(`Timestamp: ${data.timestamp}`);
console.log('Summary:');
console.log(`  Total: ${data.summary.total_checks}`);
console.log(`  Passed: ${data.summary.passed}`);
console.log(`  Failed: ${data.summary.failed}`);
console.log(`  Duration: ${data.summary.duration_ms} ms`);
console.log('\nChecks:');
for (const [name, result] of Object.entries(data.checks || {})) {
  const status = result.exit_code === 0 ? '✅' : '❌';
  console.log(`  ${status} ${name} (exit ${result.exit_code}, ${result.duration_ms} ms)`);
}
