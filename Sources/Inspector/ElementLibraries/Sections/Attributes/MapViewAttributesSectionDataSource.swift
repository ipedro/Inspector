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

import InspectorContract
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

        var propertyBindings: [InspectorPropertyBinding] {
            guard let mapView else { return [] }

            return Property.allCases.compactMap { property in
                switch property {
                case .type:
                    return .init(
                        descriptor: .init(
                            id: "type",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(.init(options: MKMapType.allCases.enumerated().map {
                                .init(id: "\($0.offset)", title: $0.element.description)
                            }, allowsNil: true)),
                            editability: .editable
                        ),
                        read: { .selection(MKMapType.allCases.firstIndex(of: mapView.mapType)) },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            mapView.mapType = MKMapType.allCases[index]
                        }
                    )
                case .groupAllows, .groupShows:
                    return .init(
                        descriptor: .init(
                            id: property.rawValue.replacingOccurrences(of: " ", with: "-").lowercased(),
                            title: property.rawValue,
                            kind: .group,
                            value: .none,
                            editability: .readOnly
                        ),
                        read: { .none },
                        write: nil,
                        refreshHint: .none
                    )
                case .isZoomEnabled:
                    return .init(descriptor: .init(id: "is-zoom-enabled", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(mapView.isZoomEnabled) }, write: { newValue in guard case let .bool(v)=newValue else { return }; mapView.isZoomEnabled = v })
                case .isRotateEnabled:
                    return .init(descriptor: .init(id: "is-rotate-enabled", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(mapView.isRotateEnabled) }, write: { newValue in guard case let .bool(v)=newValue else { return }; mapView.isRotateEnabled = v })
                case .isScrollEnabled:
                    return .init(descriptor: .init(id: "is-scroll-enabled", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(mapView.isScrollEnabled) }, write: { newValue in guard case let .bool(v)=newValue else { return }; mapView.isScrollEnabled = v })
                case .isPitchEnabled:
                    return .init(descriptor: .init(id: "is-pitch-enabled", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(mapView.isPitchEnabled) }, write: { newValue in guard case let .bool(v)=newValue else { return }; mapView.isPitchEnabled = v })
                case .buildings:
                    return .init(descriptor: .init(id: "shows-buildings", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(mapView.showsBuildings) }, write: { newValue in guard case let .bool(v)=newValue else { return }; mapView.showsBuildings = v })
                case .showsScale:
                    return .init(descriptor: .init(id: "shows-scale", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(mapView.showsScale) }, write: { newValue in guard case let .bool(v)=newValue else { return }; mapView.showsScale = v })
                case .pointOfInterestFilter:
                    return .init(
                        descriptor: .init(
                            id: "point-of-interest-filter",
                            title: property.rawValue,
                            kind: .options,
                            value: .selection(.init(options: (["None"] + MKPointOfInterestFilter.allCases.map(\.displayName)).enumerated().map {
                                .init(id: "\($0.offset)", title: $0.element)
                            }, allowsNil: true)),
                            editability: .editable
                        ),
                        read: {
                            guard let filter = mapView.pointOfInterestFilter,
                                  let selectedIndex = MKPointOfInterestFilter.allCases.firstIndex(of: filter) else {
                                return .selection(0)
                            }
                            return .selection(selectedIndex + 1)
                        },
                        write: { newValue in
                            guard case let .selection(index) = newValue, let index else { return }
                            guard index > 0 else {
                                mapView.pointOfInterestFilter = .none
                                return
                            }
                            mapView.pointOfInterestFilter = MKPointOfInterestFilter.allCases[index - 1]
                        }
                    )
                case .showsUserLocation:
                    return .init(descriptor: .init(id: "shows-user-location", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(mapView.showsUserLocation) }, write: { newValue in guard case let .bool(v)=newValue else { return }; mapView.showsUserLocation = v })
                case .showsTraffic:
                    return .init(descriptor: .init(id: "shows-traffic", title: property.rawValue, kind: .toggle, value: .bool, editability: .editable), read: { .bool(mapView.showsTraffic) }, write: { newValue in guard case let .bool(v)=newValue else { return }; mapView.showsTraffic = v })
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
        default: rawValue.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}
