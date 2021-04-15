//
//  MKMapViewSectionViewModel.swift
//  HierarchyInspector
//
//  Created by Pedro Almeida on 03.12.20.
//

import MapKit

extension UIKitComponents {
    
    final class MKMapViewInspectableViewModel: HierarchyInspectableElementViewModelProtocol {
        
        enum Property: String, Swift.CaseIterable {
            case type                  = "Type"
            case groupAllows           = "Allows"
            case isZoomEnabled         = "Zooming"
            case isRotateEnabled       = "Rotating"
            case isScrollEnabled       = "Scrolling"
            case isPitchEnabled        = "3D View"
            case groupShows            = "Shows"
            case buildings             = "Buildings"
            case showsScale            = "Scale"
            case showsPointsOfInterest = "Points of Interest"
            case showsUserLocation     = "User Location"
            case showsTraffic          = "Traffic"
        }
        
        let title = "Map View"
        
        private(set) weak var mapView: MKMapView?
        
        init?(view: UIView) {
            guard let mapView = view as? MKMapView else {
                return nil
            }
            
            self.mapView = mapView
        }
        
        private(set) lazy var properties: [HiearchyInspectableElementProperty] = Property.allCases.compactMap { property in
            guard let mapView = mapView else {
                return nil
            }

            switch property {
            
            case .type:
                return .optionsList(
                    title: property.rawValue,
                    options: MKMapType.allCases.map { $0.description },
                    selectedIndex: { MKMapType.allCases.firstIndex(of: mapView.mapType) }
                ) {
                    guard let newIndex = $0 else {
                        return
                    }
                    
                    let mapType = MKMapType.allCases[newIndex]
                    
                    mapView.mapType = mapType
                }
                
            case .groupAllows:
                return .group(title: property.rawValue)
                
            case .isZoomEnabled:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { mapView.isZoomEnabled }
                ) { isZoomEnabled in
                    mapView.isZoomEnabled = isZoomEnabled
                }
                
            case .isRotateEnabled:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { mapView.isRotateEnabled }
                ) { isRotateEnabled in
                    mapView.isRotateEnabled = isRotateEnabled
                }
                
            case .isScrollEnabled:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { mapView.isScrollEnabled }
                ) { isScrollEnabled in
                    mapView.isScrollEnabled = isScrollEnabled
                }
                
            case .isPitchEnabled:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { mapView.isPitchEnabled }
                ) { isPitchEnabled in
                    mapView.isPitchEnabled = isPitchEnabled
                }
                
            case .groupShows:
                return .group(title: property.rawValue)
                
            case .buildings:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { mapView.showsBuildings }
                ) { showsBuildings in
                    mapView.showsBuildings = showsBuildings
                }
                
            case .showsScale:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { mapView.showsScale }
                ) { showsScale in
                    mapView.showsScale = showsScale
                }
                
            case .showsPointsOfInterest:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { mapView.showsPointsOfInterest }
                ) { showsPointsOfInterest in
                    mapView.showsPointsOfInterest = showsPointsOfInterest
                }
                
            case .showsUserLocation:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { mapView.showsUserLocation }
                ) { showsUserLocation in
                    mapView.showsUserLocation = showsUserLocation
                }
                
            case .showsTraffic:
                return .toggleButton(
                    title: property.rawValue,
                    isOn: { mapView.showsTraffic }
                ) { showsTraffic in
                    mapView.showsTraffic = showsTraffic
                }
                
            }
            
        }
        
    }
    
}
