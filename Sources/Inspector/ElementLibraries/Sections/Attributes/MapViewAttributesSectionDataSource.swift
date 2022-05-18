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
            guard let mapView = mapView else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .type:
                    return .optionsList(
                        title: property.rawValue,
                        options: MKMapType.allCases.map(\.description),
                        selectedIndex: { MKMapType.allCases.firstIndex(of: mapView.mapType) }
                    ) {
                        guard let newIndex = $0 else { return }

                        let mapType = MKMapType.allCases[newIndex]

                        mapView.mapType = mapType
                    }
                case .groupAllows, .groupShows:
                    return .group(title: property.rawValue)

                case .isZoomEnabled:
                    return .switch(
                        title: property.rawValue,
                        isOn: { mapView.isZoomEnabled }
                    ) { isZoomEnabled in
                        mapView.isZoomEnabled = isZoomEnabled
                    }
                case .isRotateEnabled:
                    return .switch(
                        title: property.rawValue,
                        isOn: { mapView.isRotateEnabled }
                    ) { isRotateEnabled in
                        mapView.isRotateEnabled = isRotateEnabled
                    }
                case .isScrollEnabled:
                    return .switch(
                        title: property.rawValue,
                        isOn: { mapView.isScrollEnabled }
                    ) { isScrollEnabled in
                        mapView.isScrollEnabled = isScrollEnabled
                    }
                case .isPitchEnabled:
                    return .switch(
                        title: property.rawValue,
                        isOn: { mapView.isPitchEnabled }
                    ) { isPitchEnabled in
                        mapView.isPitchEnabled = isPitchEnabled
                    }
                case .buildings:
                    return .switch(
                        title: property.rawValue,
                        isOn: { mapView.showsBuildings }
                    ) { showsBuildings in
                        mapView.showsBuildings = showsBuildings
                    }
                case .showsScale:
                    return .switch(
                        title: property.rawValue,
                        isOn: { mapView.showsScale }
                    ) { showsScale in
                        mapView.showsScale = showsScale
                    }
                case .pointOfInterestFilter:
                    return .optionsList(
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
                    return .switch(
                        title: property.rawValue,
                        isOn: { mapView.showsUserLocation }
                    ) { showsUserLocation in
                        mapView.showsUserLocation = showsUserLocation
                    }
                case .showsTraffic:
                    return .switch(
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

extension MKPointOfInterestFilter: CaseIterable {
    static let allCases: [MKPointOfInterestFilter] = [
        .includingAll,
        .excludingAll
    ]

    open var displayName: String {
        switch self {
        case .includingAll:
            return "Including All"
        case .excludingAll:
            return "Excluding All"
        default:
            return MKPointOfInterestCategory.allCases
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
        case .airport: return "Airport"
        case .amusementPark: return "Amusement Park"
        case .aquarium: return "Aquarium"
        case .atm: return "Atm"
        case .bakery: return "Bakery"
        case .bank: return "Bank"
        case .beach: return "Beach"
        case .brewery: return "Brewery"
        case .cafe: return "Cafe"
        case .campground: return "Campground"
        case .carRental: return "Car Rental"
        case .evCharger: return "EV Charger"
        case .fireStation: return "Fire Station"
        case .fitnessCenter: return "Fitness Center"
        case .foodMarket: return "Food Market"
        case .gasStation: return "Gas Station"
        case .hospital: return "Hospital"
        case .hotel: return "Hotel"
        case .laundry: return "Laundry"
        case .library: return "Library"
        case .marina: return "Marina"
        case .movieTheater: return "Movie Theater"
        case .museum: return "Museum"
        case .nationalPark: return "National Park"
        case .nightlife: return "Nightlife"
        case .park: return "Park"
        case .parking: return "Parking"
        case .pharmacy: return "Pharmacy"
        case .police: return "Police"
        case .postOffice: return "Post Office"
        case .publicTransport: return "Public Transport"
        case .restaurant: return "Restaurant"
        case .restroom: return "Restroom"
        case .school: return "School"
        case .stadium: return "Stadium"
        case .store: return "Store"
        case .theater: return "Theater"
        case .university: return "University"
        case .winery: return "Winery"
        case .zoo: return "Zoo"
        default: return "Unknown"
        }
    }
}
