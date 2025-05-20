//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import MapKit

extension DefaultElementAttributesLibrary {
    final class MapViewAttributesSectionDataSource: InspectorElementSectionDataSource {
        var state: InspectorElementSectionState = .collapsed

        let title = "Map View"

        private weak var mapView: MKMapView?

        init?(with object: NSObject) {
            guard let mapView = object as? MKMapView else { return nil }
            self.mapView = mapView
        }

        private enum Property: String, Swift.CaseIterable {
            case type = "Type"
            case groupAllows = "Allows"
            case isZoomEnabled = "Zooming"
            case isRotateEnabled = "Rotating"
            case isScrollEnabled = "Scrolling"
            case isPitchEnabled = "3D View"
            case groupShows = "Shows"
            case buildings = "Buildings"
            case showsScale = "Scale"
            case pointOfInterestFilter = "Points of Interest"
            case showsUserLocation = "User Location"
            case showsTraffic = "Traffic"
        }

        var properties: [InspectorElementProperty] {
            guard let mapView else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .type:
                    .optionsList(
                        title: property.rawValue,
                        options: MKMapType.allCases.map(\.description),
                        selectedIndex: { MKMapType.allCases.firstIndex(of: mapView.mapType) }
                    ) {
                        guard let newIndex = $0 else { return }

                        let mapType = MKMapType.allCases[newIndex]

                        mapView.mapType = mapType
                    }
                case .groupAllows, .groupShows:
                    .group(title: property.rawValue)
                case .isZoomEnabled:
                    .switch(
                        title: property.rawValue,
                        isOn: { mapView.isZoomEnabled }
                    ) { isZoomEnabled in
                        mapView.isZoomEnabled = isZoomEnabled
                    }
                case .isRotateEnabled:
                    .switch(
                        title: property.rawValue,
                        isOn: { mapView.isRotateEnabled }
                    ) { isRotateEnabled in
                        mapView.isRotateEnabled = isRotateEnabled
                    }
                case .isScrollEnabled:
                    .switch(
                        title: property.rawValue,
                        isOn: { mapView.isScrollEnabled }
                    ) { isScrollEnabled in
                        mapView.isScrollEnabled = isScrollEnabled
                    }
                case .isPitchEnabled:
                    .switch(
                        title: property.rawValue,
                        isOn: { mapView.isPitchEnabled }
                    ) { isPitchEnabled in
                        mapView.isPitchEnabled = isPitchEnabled
                    }
                case .buildings:
                    .switch(
                        title: property.rawValue,
                        isOn: { mapView.showsBuildings }
                    ) { showsBuildings in
                        mapView.showsBuildings = showsBuildings
                    }
                case .showsScale:
                    .switch(
                        title: property.rawValue,
                        isOn: { mapView.showsScale }
                    ) { showsScale in
                        mapView.showsScale = showsScale
                    }
                case .pointOfInterestFilter:
                    .optionsList(
                        title: property.rawValue,
                        options: ["None"] + MKPointOfInterestFilter.allCases.map(\.displayName),
                        selectedIndex: {
                            guard
                                let pointOfInterestFilter = mapView.pointOfInterestFilter,
                                let selectedIndex = MKPointOfInterestFilter.allCases.firstIndex(of: pointOfInterestFilter)
                            else {
                                return .zero
                            }
                            return selectedIndex + 1
                        },
                        handler: {
                            guard let newIndex = $0, newIndex > .zero else {
                                mapView.pointOfInterestFilter = .none
                                return
                            }

                            let pointOfInterestFilter = MKPointOfInterestFilter.allCases[newIndex - 1]

                            mapView.pointOfInterestFilter = pointOfInterestFilter
                        }
                    )
                case .showsUserLocation:
                    .switch(
                        title: property.rawValue,
                        isOn: { mapView.showsUserLocation }
                    ) { showsUserLocation in
                        mapView.showsUserLocation = showsUserLocation
                    }
                case .showsTraffic:
                    .switch(
                        title: property.rawValue,
                        isOn: { mapView.showsTraffic }
                    ) { showsTraffic in
                        mapView.showsTraffic = showsTraffic
                    }
                }
            }
        }
    }
}

extension MKPointOfInterestFilter {
    static let allCases: [MKPointOfInterestFilter] = [
        .includingAll,
        .excludingAll
    ]

    public var displayName: String {
        switch self {
        case .includingAll:
            "Including All"
        case .excludingAll:
            "Excluding All"
        default:
            MKPointOfInterestCategory.allCases
                .compactMap { includes($0) ? $0.description : .none }
                .joined(separator: ", ")
        }
    }
}

extension MKPointOfInterestCategory: CaseIterable, CustomStringConvertible {
    static let allCases: [MKPointOfInterestCategory] = [
        .airport,
        .amusementPark,
        .aquarium,
        .atm,
        .bakery,
        .bank,
        .beach,
        .brewery,
        .cafe,
        .campground,
        .carRental,
        .evCharger,
        .fireStation,
        .fitnessCenter,
        .foodMarket,
        .gasStation,
        .hospital,
        .hotel,
        .laundry,
        .library,
        .marina,
        .movieTheater,
        .museum,
        .nationalPark,
        .nightlife,
        .park,
        .parking,
        .pharmacy,
        .police,
        .postOffice,
        .publicTransport,
        .restaurant,
        .restroom,
        .school,
        .stadium,
        .store,
        .theater,
        .university,
        .winery,
        .zoo
    ]

    var description: String {
        switch self {
        case .airport: "Airport"
        case .amusementPark: "Amusement Park"
        case .aquarium: "Aquarium"
        case .atm: "Atm"
        case .bakery: "Bakery"
        case .bank: "Bank"
        case .beach: "Beach"
        case .brewery: "Brewery"
        case .cafe: "Cafe"
        case .campground: "Campground"
        case .carRental: "Car Rental"
        case .evCharger: "EV Charger"
        case .fireStation: "Fire Station"
        case .fitnessCenter: "Fitness Center"
        case .foodMarket: "Food Market"
        case .gasStation: "Gas Station"
        case .hospital: "Hospital"
        case .hotel: "Hotel"
        case .laundry: "Laundry"
        case .library: "Library"
        case .marina: "Marina"
        case .movieTheater: "Movie Theater"
        case .museum: "Museum"
        case .nationalPark: "National Park"
        case .nightlife: "Nightlife"
        case .park: "Park"
        case .parking: "Parking"
        case .pharmacy: "Pharmacy"
        case .police: "Police"
        case .postOffice: "Post Office"
        case .publicTransport: "Public Transport"
        case .restaurant: "Restaurant"
        case .restroom: "Restroom"
        case .school: "School"
        case .stadium: "Stadium"
        case .store: "Store"
        case .theater: "Theater"
        case .university: "University"
        case .winery: "Winery"
        case .zoo: "Zoo"
        default: "Unknown"
        }
    }
}
