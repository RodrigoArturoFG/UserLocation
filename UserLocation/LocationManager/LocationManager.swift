//
//  LocationManager.swift
//  UserLocation
//
//  Created by Fernández González Rodrigo Arturo on 10/10/24.
//
import UIKit
import CoreLocation

enum LocationManagerErorr: Int, Error {
    case locationAuthDenied = 1
    case locationReducedAccuracy = 2
    case obtenerUbicacion = 3
    case unknownError
    
    init(value: Int) {
        self = LocationManagerErorr(rawValue: value) ?? .unknownError
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    //MARK: Objeto para acceder a los servicios de localización
    private let locationManager = CLLocationManager()
    
    //MARK: Objeto para saber si se esta rastreando la ubicación del Usuario
    private var isUpdatingLocations = Bool()
    
    //MARK: Objeto para solicitar la precisión completa, quizá quitar
    private var propourseMessage = ""
    
    //MARK: Configurar el Location Manager Delegate
    override init() {
        super.init()
        locationManager.delegate = self
        self.requestAuthorization()
        /*
        // Obtener ubicación en segundo
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        */
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
    func checkAuthorization(completionHandler:@escaping (_ success:Bool, _ error_code: Int) -> Void)  {
        switch locationManager.authorizationStatus {
        case .denied:
            // Si el usuario seleccionó la opción nunca, se debe solicitar dicho permiso.
            completionHandler(false, LocationManagerErorr.locationAuthDenied.rawValue)
        default:
            completionHandler(true, 0)
        }
    }
    
    //MARK: Comprueba el nivel de precisión de la ubicación que la aplicación tiene permiso para usar.
    func checkAccuracy(completionHandler:@escaping (_ success:Bool, _ error_code: Int) -> Void)  {
        switch locationManager.accuracyAuthorization {
        case .reducedAccuracy:
            // Si el usuario ha optado por otorgar a esta aplicación acceso a información de ubicación con precisión reducida, entonces se debe requerir al usuario la ubicación precisa de maner obligatoria.
            completionHandler(false, LocationManagerErorr.locationReducedAccuracy.rawValue)
        default:
            completionHandler(true, 0)
        }
    }
    
    //MARK: Comprueba el nivel de precisión de la ubicación que la aplicación tiene permiso para usar.
    func requestAccuracy(completionHandler:@escaping (_ success:Bool, _ error_code: Int, _ message: String?) -> Void)  {
        Task{
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: propourseMessage, completion: { (error) in
                if error != nil {
                    completionHandler(true, LocationManagerErorr.locationReducedAccuracy.rawValue, "Ocurrió un error al solicitar la ubicación precisa: \(error.debugDescription)")
                }else {
                    completionHandler(false, 0, "Ubicación Precisa")
                }
            })
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
        //primero checar si la app tiene autorización del usuario para usar la ubicación
        Task{
            self.checkAuthorization { success, error_code  in
                if success == false {
                    completionHandler(false, nil, LocationManagerErorr.locationAuthDenied.rawValue, "Tu ubicación actual no se puede determinar en este momento. \n Puedes abrir la configuración de la app para permitir el acceso a la ubicación.")
                }else{
                    if(precisa)
                    {
                        // parametro precisa = True
                        self.propourseMessage = propourseMessage
                        Task {
                            self.checkAccuracy { success, error_code in
                                if success == false {
                                    completionHandler(false, nil, LocationManagerErorr.locationReducedAccuracy.rawValue, "Para hacer uso de esta funcionalidad la app requiere hacer uso de tu ubicación precisa.")
                                }else{
                                    // Precisa = True y la app tiene autorización del usuario para usar la ubicación
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
                                            // Ocurrió un error al obtener la ubicación del usuario
                                            completionHandler(false, nil, LocationManagerErorr.obtenerUbicacion.rawValue, "No se pudo obtener la ubicación del usuario: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                        }
                    }else{
                        // paramatro precisa = False
                        Task {
                            // Precisa = False y la app tiene autorización del usuario para usar la ubicación
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
                                // Ocurrió un error al obtener la ubicación del usuario
                                completionHandler(false, nil, LocationManagerErorr.obtenerUbicacion.rawValue, "No se pudo obtener la ubicación del usuario: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Ir a la configuración de la app
    func abrirConfiguracion(){
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: iniciar un rastreo de la ubicación del usuario, devolviendo cada cierto tiempo la ubicación del usuario
    func iniciarRastreoUbicacionUsuario(precisa:Bool, propourseMessage:String, completionHandler:@escaping (_ success:Bool, _ location:CLLocationCoordinate2D?, _ error_code: Int, _ message:String?) -> Void){
        
        self.iniciarRastreo()
        
        //primero checar si la app tiene autorización del usuario para usar la ubicación
        Task{
            self.checkAuthorization { success, error_code  in
                if success == false {
                    self.detenerRastreoUbicacionUsuario()
                    completionHandler(false, nil, LocationManagerErorr.locationAuthDenied.rawValue, "Tu ubicación actual no se puede determinar en este momento. \n Puedes abrir la configuración de la app para permitir el acceso a la ubicación.")
                }else{
                    if(precisa)
                    {
                        // paramatro precisa = True
                        self.propourseMessage = propourseMessage
                        Task {
                            self.checkAccuracy { success, error_code in
                                if success == false {
                                    completionHandler(false, nil, LocationManagerErorr.locationReducedAccuracy.rawValue, "Para hacer uso de esta funcionalidad la app requiere hacer uso de tu ubicación precisa.")
                                }else{
                                    // Precisa = True y la app tiene autorización del usuario para usar la ubicación
                                    Task {
                                        var location: CLLocation?
                                        do {
                                            repeat {
                                                // Se obtiene la ubicación actual
                                                location = try await self.currentLocation
                                                
                                                // Se asignan los valores correspondientes de la ubicación actual a un objeto de tipo CLLocationCoordinate2D
                                                let locationCoordinate = CLLocationCoordinate2D(
                                                    latitude: location!.coordinate.latitude,
                                                    longitude: location!.coordinate.longitude
                                                )
                                                
                                                completionHandler(true, locationCoordinate, 0, "Ubicación actual del usuario")
                                            } while self.isUpdatingLocations
                                        } catch {
                                            // Ocurrió un error al obtener la ubicación del usuario
                                            completionHandler(false, nil, LocationManagerErorr.obtenerUbicacion.rawValue, "No se pudo obtener la ubicación del usuario: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                        }
                    }else{
                        // paramatro precisa = False
                        Task {
                            // Precisa = False y la app tiene autorización del usuario para usar la ubicación
                            var location: CLLocation?
                            do {
                                repeat {
                                    // Se obtiene la ubicación actual
                                    location = try await self.currentLocation
                                    
                                    // Se asignan los valores correspondientes de la ubicación actual a un objeto de tipo CLLocationCoordinate2D
                                    let locationCoordinate = CLLocationCoordinate2D(
                                        latitude: location!.coordinate.latitude,
                                        longitude: location!.coordinate.longitude
                                    )
                                    
                                    completionHandler(true, locationCoordinate, 0, "Ubicación actual del usuario")
                                } while self.isUpdatingLocations
                            } catch {
                                // Ocurrió un error al obtener la ubicación del usuario
                                completionHandler(false, nil, LocationManagerErorr.obtenerUbicacion.rawValue, "No se pudo obtener la ubicación del usuario: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK:  Este método debe detener el rastreo de la ubicación del usuario
    func iniciarRastreo(){
        locationManager.startUpdatingLocation()
        isUpdatingLocations = true
    }
    
    // MARK:  Este método debe detener el rastreo de la ubicación del usuario sin completionHandler
    func detenerRastreoUbicacionUsuario(){
        locationManager.stopUpdatingLocation()
        isUpdatingLocations = false
    }
    
    // MARK:  Este método debe detener el rastreo de la ubicación del usuario con completionHandler
    func detenerRastreoUbicacionUsuario(completionHandler:@escaping (_ success:Bool, _ error_code: Int, _ message:String?) -> Void){
        Task{
            locationManager.stopUpdatingLocation()
            isUpdatingLocations = false
            completionHandler(true, 0, "Se detuvo el rastreo de la ubicación del usuario")
            // checar si hay algún metodo delegado que nos pueda informar si ocurrión un error, ya que este es el único metodo para detener el rastreo y no regresa ninguna respuesta
        }
    }
        
    // MARK: CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Si hay una ubicación disponible
        // Check if Requests the one-time delivery of the user’s current location or
        // Starts the generation of updates that report the user’s current location
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
            // El usuario aún no ha hecho una elección con respecto a la ubicación de esta aplicación
            // Cuando el usuario selecciona la opción "Preguntar la próxima vez o al compartirla" desde las configuraciones SI SE SOLICITA la autorización "Al usar la app"
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            // El usuario ha otorgado autorización para usar su ubicación solo mientras usa su aplicación
            // Por alguna razón el sistema NO SE SOLICITA la aturización "Siempre" cuando se selecciona "Al usar la app" desde las configuraciones y se regresa a la app.
            locationManager.requestAlwaysAuthorization()
        default:
            return
        }
    }
    
}
