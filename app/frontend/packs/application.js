require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import Rails from 'rails-ujs';

import { initAll } from 'govuk-frontend';

import 'leaflet/dist/leaflet.css';
import 'leaflet.markercluster/dist/MarkerCluster.css';
import 'leaflet-gesture-handling/dist/leaflet-gesture-handling.css';

import 'src/application';
import 'src/components';

import 'src/styles/application.scss';

Rails.start();

initAll();
