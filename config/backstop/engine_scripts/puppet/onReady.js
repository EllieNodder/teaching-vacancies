module.exports = async (page, scenario, vp) => {
  console.log('SCENARIO ON READY > ' + scenario.label);
  await require('./clickAndHoverHelper')(page, scenario);

  await page.waitForNavigation();

  const cookies = await browserContext.cookies();

  // console.log('sdfdsf', cookies)

  const [sessionCookie] = cookies.filter((c) => c.name === '_teachingvacancies_session');

  const cookieData = [];

  cookieData.push({
    "name": sessionCookie.name,
    "value": sessionCookie.value,
    "domain": sessionCookie.domain,
    "path": sessionCookie.path,
    "expires": sessionCookie.expires,
    "httpOnly": sessionCookie.httpOnly,
    "secure": sessionCookie.secure,
    "sameSite": sessionCookie.sameSite
  });

  const fsPromises = fs.promises;
  
  fsPromises.writeFile('config/backstop/cookies.json', JSON.stringify(cookieData), (err) => {
    if (err) {
        throw err;
    }
    console.log("JSON data is saved.");
  });

  // add more ready handlers here...

};
