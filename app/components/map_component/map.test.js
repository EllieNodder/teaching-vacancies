/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';

import MapController from './map_component';
import map from './map';

let application;

const initialiseStimulus = () => {
  application = Application.start();
  application.register('map', MapController);
};

jest.mock('../../frontend/src/lib/api');

const mockCreateMap = jest.fn();
const mockAddToMap = jest.fn();
const mockCreateCluster = jest.fn();
const mockCreatePolygon = jest.fn();
const mockCreateCircle = jest.fn();
const mockLayerBounds = jest.fn();
const mockAddMarkerToCluster = jest.fn();
const mockSetMapBounds = jest.fn();
const mockCreateMarker = jest.fn();

let spies;

const getMarkerHTML = (count) => {
  let markerHTML = '';
  for (let step = 0; step < count; step += 1) {
    markerHTML += '<div data-map-target="marker" data-lat="51" data-lon="0.14"></div>';
  }
  return markerHTML;
};

beforeEach(() => {
  document.body.innerHTML = `<div class="map-component" id="map-component" data-controller="map">
  <div id="markers"></div>
  <div class="map-component__map" id="map"></div>
  </div>`;
  jest.resetAllMocks();
});

beforeAll(() => {
  jest.mock('./map_component', () => jest.fn().mockImplementation(() => ({
    addToMap: mockAddToMap,
    addMarkerToCluster: mockAddMarkerToCluster,
    setMapBounds: mockSetMapBounds,
  })));

  jest.mock('./map', () => jest.fn().mockImplementation(() => ({
    create: mockCreateMap,
    createCluster: mockCreateCluster,
    createMarker: mockCreateMarker,
    createPolygon: mockCreatePolygon,
    createCircle: mockCreateCircle,
    layerBounds: mockLayerBounds,
  })));

  spies = {
    createMap: jest.spyOn(map, 'create'),
    createPolygon: jest.spyOn(map, 'createPolygon'),
    createCircle: jest.spyOn(map, 'createCircle'),
    createCluster: jest.spyOn(map, 'createCluster'),
    createMarker: jest.spyOn(map, 'createMarker'),
    layerBounds: jest.spyOn(map, 'layerBounds'),
    addToMap: jest.spyOn(MapController.prototype, 'addToMap'),
    addMarkerToCluster: jest.spyOn(MapController.prototype, 'addMarkerToCluster'),
    setMapBounds: jest.spyOn(MapController.prototype, 'setMapBounds'),
  };
});

describe('when map is initialised with one marker', () => {
  beforeEach(() => {
    document.getElementById('markers').insertAdjacentHTML('afterbegin', getMarkerHTML(1));
    jest.resetAllMocks();
    initialiseStimulus();
  });

  test('a map object is created', () => {
    expect(spies.createMap).toHaveBeenCalledWith({ lat: '51', lon: '0.14' }, MapController.DEFAULT_ZOOM);
    expect(spies.createCluster).toHaveBeenCalledTimes(1);
  });

  test('one marker is added to map', () => {
    expect(spies.createMarker).toHaveBeenCalledTimes(1);
    expect(spies.addMarkerToCluster).not.toHaveBeenCalled();
    expect(spies.addToMap).toHaveBeenCalledTimes(1);
    expect(spies.setMapBounds).not.toHaveBeenCalled();
  });
});

describe('when map is initialised with polygons', () => {
  beforeEach(() => {
    document.getElementById('markers').insertAdjacentHTML('afterbegin', getMarkerHTML(1));
    document.getElementById('map-component').setAttribute('data-polygons', '[[[0, 0],[0, 2],[2, 2]], [[0, 0],[0, 1],[1, 1]]]');
    jest.resetAllMocks();
    initialiseStimulus();
  });

  test('a map object is created', () => {
    expect(spies.createMap).toHaveBeenCalledWith({ lat: '51', lon: '0.14' }, MapController.DEFAULT_ZOOM);
    expect(spies.createCluster).toHaveBeenCalledTimes(1);
  });

  test('one marker and polygons are added to map', () => {
    expect(spies.createMarker).toHaveBeenCalledTimes(1);
    expect(spies.createPolygon).toHaveBeenNthCalledWith(1, { coordinates: [[0, 0], [0, 2], [2, 2]] });
    expect(spies.createPolygon).toHaveBeenNthCalledWith(2, { coordinates: [[0, 0], [0, 1], [1, 1]] });
    expect(spies.addMarkerToCluster).not.toHaveBeenCalled();
    expect(spies.addToMap).toHaveBeenCalledTimes(3);
    expect(spies.setMapBounds).toHaveBeenCalledTimes(1);
  });
});

describe('when map is initialised with a center point and radius', () => {
  beforeEach(() => {
    document.getElementById('markers').insertAdjacentHTML('afterbegin', getMarkerHTML(1));
    document.getElementById('map-component').setAttribute('data-point', '[50,10]');
    document.getElementById('map-component').setAttribute('data-radius', '10');
    jest.resetAllMocks();
    initialiseStimulus();
  });

  test('a map object is created with location marker', () => {
    expect(spies.createMarker).toHaveBeenNthCalledWith(1, [50, 10], 'location');
    expect(spies.createMarker).toHaveBeenNthCalledWith(2, { lat: '51', lon: '0.14' }, 'pin', expect.any(Function));
  });

  test('a circle showing radius is added to map', () => {
    expect(spies.createPolygon).toHaveBeenCalledTimes(0);
    expect(spies.createCircle).toHaveBeenCalledWith('10', [50, 10]);
    expect(spies.addToMap).toHaveBeenCalledTimes(3);
    expect(spies.layerBounds).toHaveBeenCalled();
    expect(spies.setMapBounds).toHaveBeenCalledTimes(1);
  });
});

describe('when map is initialised with more than one marker', () => {
  beforeEach(() => {
    document.getElementById('markers').insertAdjacentHTML('afterbegin', getMarkerHTML(2));
    jest.resetAllMocks();
    initialiseStimulus();
  });

  test('a map object is created', () => {
    expect(spies.createMap).toHaveBeenCalledWith({ lat: '51', lon: '0.14' }, MapController.DEFAULT_ZOOM);
    expect(spies.createCluster).toHaveBeenCalledTimes(1);
  });

  test('markers are added to cluster', () => {
    expect(spies.createMarker).toHaveBeenCalledTimes(2);
    expect(spies.addMarkerToCluster).toHaveBeenCalledTimes(2);
    expect(spies.addToMap).toHaveBeenCalledTimes(1);
    expect(spies.setMapBounds).toHaveBeenCalledWith([{ lat: '51', lon: '0.14' }, { lat: '51', lon: '0.14' }]);
  });
});
