//
//  LocationManager.swift
//  UserLocation
//
//  Created by Fernández González Rodrigo Arturo on 10/10/24.
//
import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    //MARK: Objeto para acceder a los servicios de localización
    private let locationManager = CLLocationManager()
    
    //MARK: Configurar el Location Manager Delegate
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    //MARK: Solicitar autorización para acceder a la ubicación del usuario
    func checkAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            //locationManager.requestWhenInUseAuthorization()
            locationManager.requestAlwaysAuthorization()
        default:
            return
        }
    }
    
    //MARK: Objeto de continuación que devolverá la ubicación del usuario una vez que esté disponible
    private var continuation: CheckedContinuation<CLLocation, Error>?
    
    //MARK: Solicitud asíncrona para obtener la ubicación actual
    var currentLocation: CLLocation {
        get async throws {
            return try await withCheckedThrowingContinuation { continuation in
                // 1. Set up the continuation object
                self.continuation = continuation
                // 2. Triggers the update of the current location
                locationManager.requestLocation()
            }
        }
    }
    
    // MARK: Obtener la ubicación actual del usuario si está disponible
    func obtenerUbicacionUsuario(precisa:Bool, propourseMessage:String, completionHandler:@escaping (_ success:Bool, _ location:CLLocationCoordinate2D?, _ error_code: Int, _ message:String?) -> Void) {

        Task {
            var location: CLLocation?
            do {
                // Get the current location from the location manager
                location = try await self.currentLocation
                
                let locationCoordinate = CLLocationCoordinate2D(
                    latitude: location!.coordinate.latitude,
                    longitude: location!.coordinate.longitude
                )
                
                completionHandler(true, locationCoordinate, 0, "cualquier cosa")
            } catch {
                print("Could not get user location: \(error.localizedDescription)")
                completionHandler(true, nil, 0, "Could not get user location: \(error.localizedDescription)")
            }
        }

    }
    
    // MARK: Ir a la configuración de la app
    func abrirConfiguracion(){
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 4. If there is a location available
        if let lastLocation = locations.last {
            // 5. Resumes the continuation object with the user location as result
            continuation?.resume(returning: lastLocation)
            // Resets the continuation object
            continuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 6. If not possible to retrieve a location, resumes with an error
        continuation?.resume(throwing: error)
        // Resets the continuation object
        continuation = nil
    }
    
}
