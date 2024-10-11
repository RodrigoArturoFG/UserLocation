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
        self.requestAuthorization()
    }
    
    //MARK: Solicitar la autorización para acceder a la ubicación del usuario
    func requestAuthorization()  {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            return
        }
    }
    
    //MARK: Comprueba si la aplicación está autorizada para acceder a los servicios de ubicación del dispositivo
    func checkAuthorization(completionHandler:@escaping (_ success:Bool) -> Void)  {
        switch locationManager.authorizationStatus {
        case .denied:
            print("Si el usuario seleccionó la opción nunca, se debe solicitar dicho permiso.")
            completionHandler(false)
        default:
            completionHandler(true)
        }
    }
    
    //MARK: Objeto de continuación que devolverá la ubicación del usuario una vez que esté disponible
    private var continuation: CheckedContinuation<CLLocation, Error>?
    
    //MARK: Solicitud asíncrona para obtener la ubicación actual
    var currentLocation: CLLocation {
        get async throws {
            return try await withCheckedThrowingContinuation { continuation in
                self.continuation = continuation
                // Dispara la actualización de la ubicación actual
                locationManager.requestLocation()
            }
        }
    }
    
    // MARK: Obtener la ubicación actual del usuario si está disponible
    func obtenerUbicacionUsuario(precisa:Bool, propourseMessage:String, completionHandler:@escaping (_ success:Bool, _ location:CLLocationCoordinate2D?, _ error_code: Int, _ message:String?) -> Void) {
        Task {
            var location: CLLocation?
            do {
                // Se obtiene la ubicación actual
                location = try await self.currentLocation
                
                // Se asignan los valores correspondientes de la ubicación actual a un objeto de tipo CLLocationCoordinate2D
                let locationCoordinate = CLLocationCoordinate2D(
                    latitude: location!.coordinate.latitude,
                    longitude: location!.coordinate.longitude
                )
                
                completionHandler(true, locationCoordinate, 0, "Ubicación actual del usuario")
            } catch {
                print("No se pudo obtener la ubicación del usuario: \(error.localizedDescription)")
                completionHandler(false, nil, 0, "No se pudo obtener la ubicación del usuario: \(error.localizedDescription)")
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
        // Si hay una ubicación disponible
        if let lastLocation = locations.last {
            // Reanuda el objeto de continuación con la ubicación del usuario como resultado.
            continuation?.resume(returning: lastLocation)
            // Resets the continuation object
            continuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Si no es posible recuperar una ubicación, el objeto de continuación se resume con un error
        continuation?.resume(throwing: error)
        // Se resetea el objeto de continuación
        continuation = nil
    }
    
    //MARK:  También podemos recuperar la información de ubicación del usuario cuando la aplicación está segundo plano. Para obtener la autorización "Siempre", primero se debe solicitar el permiso "Al usar la app" y luego solicitar la autorización "Siempre". Para esto usaremos el metodo delegado para saber que opción eligió el usuario //
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("El usuario aún no ha hecho una elección con respecto a la ubicación de esta aplicación.")
            // Cuando el usuario selecciona la opción "Preguntar la próxima vez o al compartirla" desde las configuraciones SI SE SOLICITA la autorización "Al usar la app"
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            print("El usuario ha otorgado autorización para usar su ubicación solo mientras usa su aplicación.")
            // Por alguna razón el sistema NO SE SOLICITA la aturización "Siempre" cuando se selecciona "Al usar la app" desde las configuraciones y se regresa a la app.
            locationManager.requestAlwaysAuthorization()
        default:
            return
        }
    }
    
}
