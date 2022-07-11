const YAML = require('yaml');
const fs = require('fs');

const testConfig = fs.readFileSync('./config/ab_tests.yml', 'utf8');

const pages = YAML.parse(testConfig).test;

module.exports.hasVariants = (page) => pages ? Object.keys(pages).find(p => p === page) : false;

module.exports.mapVariants = (scenario) => {
  const scenarios = [];
  if (pages) {
    Object.values(pages[scenario.label]).forEach((tests, i) => {
      Object.keys(tests).forEach((key) => {
        scenarios.push({...scenario, ...{
          "label": `${scenario.label} ${key}`,
          "url": `${scenario.url}?ab_test_override[${Object.keys(pages[scenario.label])[i]}]=${key}`,
        }});
      });
    })
  };
  return scenarios;
};
