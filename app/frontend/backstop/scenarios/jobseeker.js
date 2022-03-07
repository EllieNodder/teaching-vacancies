module.exports = [
  {
    "cookiePath": "app/frontend/backstop/cookies.json",
    "label": "Jobseeker my applications page",
    "url": "/jobseekers/job_applications",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      "viewport"
    ]
  },
  {
    "cookiePath": "app/frontend/backstop/cookies.json",
    "label": "Jobseeker view application page",
    "url": "/jobseekers/job_applications",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "clickSelector": ".card-component .govuk-link",
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "cookiePath": "app/frontend/backstop/cookies.json",
    "label": "Jobseeker saved jobs page",
    "url": "/jobseekers/saved_jobs",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      "viewport"
    ]
  },
  {
    "cookiePath": "app/frontend/backstop/cookies.json",
    "label": "Jobseeker view account page",
    "url": "/jobseekers/account",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      "viewport"
    ]
  }
];
