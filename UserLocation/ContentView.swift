//
//  ContentView.swift
//  UserLocation
//
//  Created by Fernández González Rodrigo Arturo on 10/10/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    // MARK: Instancia de LocationManager
    var locationManager = LocationManager()
    
    // MARK: Variable para guardar la ubicación actual del usuario
    @State var coordinateLocation: CLLocationCoordinate2D?
    
    // MARK: Variable para mostrar o no el Mapa en la Interfaz de Usuario
    @State var withMap = true
    
    @State var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.457105, longitude: -80.508361), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    //ios 17+
    //@State private var position: MapCameraPosition = .automatic
    
    var binding: Binding<MKCoordinateRegion> {
           Binding {
               self.mapRegion
           } set: { newRegion in
               self.mapRegion = newRegion
           }
       }
    
    // MARK: Variables para la presentacion de los alerts de: Obtener Ubicación
    @State private var presentAutorizationAlert = false
    @State private var messageAutorizationAlert = "Error"
    
    @State private var presentAccuracyAlert = false
    @State private var messageAccuracyAlert = "Error"
    
    // MARK: Variables para la presentacion de los alerts de: Iniciar Rastreo
    @State private var presentAutorizationTrackingAlert = false
    @State private var messageAutorizationTrackingAlert = "Error"
    
    @State private var presentAccuracyTrackingAlert = false
    @State private var messageAccuracyTrackingAlert = "Error"

    // MARK: Body
    var body: some View {
        VStack {
            if(withMap)
            {
                // Mapa para visualizar la ubicación del Usuario
                Map(coordinateRegion: $mapRegion, showsUserLocation: true,userTrackingMode: .constant(.none))
                                .edgesIgnoringSafeArea(.all)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                //ios 17+
                /*Map(position: $position) {
                    UserAnnotation()
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))*/
            }
                        
            Text("Latitud: \(self.coordinateLocation?.latitude ?? 0.0)")
                .foregroundColor(.secondary)
            
            Text("Longitud: \(self.coordinateLocation?.longitude ?? 0.0)")
                .foregroundColor(.secondary)

            // MARK: Obtener Ubicación
            Button {
                locationManager.obtenerUbicacionUsuario(precisa: false, propourseMessage: "rastreo") { success, location, error_code, message in
                    if success {
                        presentAutorizationAlert = false
                        
                        // Actualizar la posición de la cámara del mapa para centrarla alrededor de la ubicación del usuario
                        coordinateLocation = location
                        
                        if(withMap){
                            let regionSpan = MKCoordinateSpan(latitudeDelta: 0.125, longitudeDelta: 0.125)
                            mapRegion = MKCoordinateRegion(center: coordinateLocation!, span: regionSpan)
                            
                            //ios 17+
                            //self.position = .region(MKCoordinateRegion(center: coordinateLocation!, span: regionSpan))
                        }
                    }else{
                        
                        switch error_code {
                        case LocationManagerErorr.obtenerUbicacion.rawValue:
                            locationManager.checkAuthorization { success, error_code  in
                                if success == false {
                                    presentAutorizationAlert = true
                                    messageAutorizationAlert = message ?? "Tu ubicación actual no se puede determinar en este momento. \n Puedes abrir la configuración de la app para permitir el acceso a la ubicación."
                                }else{
                                    presentAutorizationAlert = false
                                    //presentar otro error
                                }
                            }
                        case LocationManagerErorr.locationAuthDenied.rawValue:
                            presentAutorizationAlert = true
                            messageAutorizationAlert = message ?? "Tu ubicación actual no se puede determinar en este momento. \n Puedes abrir la configuración de la app para permitir el acceso a la ubicación."
                        case LocationManagerErorr.locationReducedAccuracy.rawValue:
                            presentAccuracyAlert = true
                            messageAccuracyAlert = message ?? "Tu ubicación actual no se puede determinar en este momento."
                        default:
                            return
                        }

                    }
                }
            } label: {
                Text("Obtener Ubicación")
            }
            .alert(
                "Ubicación no disponible",
                isPresented: $presentAutorizationAlert,
                presenting: messageAutorizationAlert // cambiar por el codigo de error
            ) { messageAutorizationAlert in
                
                Button("Ir a Configuración") {
                    locationManager.abrirConfiguracion()
                }
                
                Button(role: .cancel) {
                    // Manejo de la cancelación.
                } label: {
                    Text("Cancelar")
                }
            } message: { messageAutorizationAlert in
                Text(messageAutorizationAlert)
            }
            .alert(
                "Precisión Reducida",
                isPresented: $presentAccuracyAlert,
                presenting: messageAccuracyAlert // cambiar por el codigo de error
            ) { messageAccuracyAlert in
                
                Button("OK") {
                    presentAccuracyAlert = false
                    locationManager.requestAccuracy { success, error_code, message in
                        // manejo de la respuesta
                        // volver a solicitar el metodo en caso de exito ??
                    }
                }
            } message: { messageAccuracyAlert in
                Text(messageAccuracyAlert)
            }
            .padding()
            
            // MARK: Obtener Ubicación (precisa = true)
            Button {
                locationManager.obtenerUbicacionUsuario(precisa: true, propourseMessage: "rastreo") { success, location, error_code, message in
                    if success {
                        presentAutorizationAlert = false
                        
                        // Actualizar la posición de la cámara del mapa para centrarla alrededor de la ubicación del usuario
                        coordinateLocation = location
                        
                        if(withMap){
                            let regionSpan = MKCoordinateSpan(latitudeDelta: 0.125, longitudeDelta: 0.125)
                            mapRegion = MKCoordinateRegion(center: coordinateLocation!, span: regionSpan)
                            
                            //ios 17+
                            //self.position = .region(MKCoordinateRegion(center: coordinateLocation!, span: regionSpan))
                        }
                    }else{
                        
                        switch error_code {
                        case LocationManagerErorr.obtenerUbicacion.rawValue:
                            locationManager.checkAuthorization { success, error_code  in
                                if success == false {
                                    presentAutorizationAlert = true
                                    messageAutorizationAlert = message ?? "Tu ubicación actual no se puede determinar en este momento. \n Puedes abrir la configuración de la app para permitir el acceso a la ubicación."
                                }else{
                                    presentAutorizationAlert = false
                                    //presentar otro error
                                }
                            }
                        case LocationManagerErorr.locationAuthDenied.rawValue:
                            presentAutorizationAlert = true
                            messageAutorizationAlert = message ?? "Tu ubicación actual no se puede determinar en este momento. \n Puedes abrir la configuración de la app para permitir el acceso a la ubicación."
                        case LocationManagerErorr.locationReducedAccuracy.rawValue:
                            presentAccuracyAlert = true
                            messageAccuracyAlert = message ?? "Tu ubicación actual no se puede determinar en este momento."
                        default:
                            return
                        }

                    }
                }
            } label: {
                Text("Obtener Ubicación (precisa = true)")
            }
            .alert(
                "Ubicación no disponible",
                isPresented: $presentAutorizationAlert,
                presenting: messageAutorizationAlert // cambiar por el codigo de error
            ) { messageAutorizationAlert in
                
                Button("Ir a Configuración") {
                    locationManager.abrirConfiguracion()
                }
                
                Button(role: .cancel) {
                    // Manejo de la cancelación.
                } label: {
                    Text("Cancelar")
                }
            } message: { messageAutorizationAlert in
                Text(messageAutorizationAlert)
            }
            .alert(
                "Precisión Reducida",
                isPresented: $presentAccuracyAlert,
                presenting: messageAccuracyAlert // cambiar por el codigo de error
            ) { messageAccuracyAlert in
                
                Button("OK") {
                    presentAccuracyAlert = false
                    locationManager.requestAccuracy { success, error_code, message in
                        // manejo de la respuesta
                        // volver a solicitar el metodo en caso de exito ??
                    }
                }
            } message: { messageAccuracyAlert in
                Text(messageAccuracyAlert)
            }
            .padding()
            
            // MARK: Iniciar Rastreo
            Button {
                locationManager.iniciarRastreoUbicacionUsuario(precisa: false, propourseMessage: "rastreo") { success, location, error_code, message in
                    if success {
                        presentAutorizationTrackingAlert = false
                        
                        // Actualizar la posición de la cámara del mapa para centrarla alrededor de la ubicación del usuario
                        coordinateLocation = location
                        
                        if(withMap){
                            let regionSpan = MKCoordinateSpan(latitudeDelta: 0.125, longitudeDelta: 0.125)
                            mapRegion = MKCoordinateRegion(center: coordinateLocation!, span: regionSpan)
                            
                            //ios 17+
                            //self.position = .region(MKCoordinateRegion(center: coordinateLocation!, span: regionSpan))
                        }
                    }else{
                        
                        switch error_code {
                        case LocationManagerErorr.obtenerUbicacion.rawValue:
                            locationManager.checkAuthorization { success, error_code  in
                                if success == false {
                                    presentAutorizationTrackingAlert = true
                                    messageAutorizationTrackingAlert = message ?? "Tu ubicación actual no se puede determinar en este momento."
                                }else{
                                    presentAutorizationTrackingAlert = false
                                    //ocurrió otro error
                                }
                            }
                        case LocationManagerErorr.locationReducedAccuracy.rawValue:
                            presentAccuracyTrackingAlert = true
                            messageAccuracyTrackingAlert = "Tu ubicación actual no se puede determinar en este momento."
                        default:
                            return
                        }

                    }
                }
            } label: {
                Text("Iniciar Rastreo")
            }
            .alert(
                "Ubicación no disponible",
                isPresented: $presentAutorizationTrackingAlert,
                presenting: messageAutorizationTrackingAlert // cambiar por el codigo de error
            ) { messageAutorizationTrackingAlert in
                
                Button("Ir a Configuración") {
                    locationManager.abrirConfiguracion()
                }
                
                Button(role: .cancel) {
                    // Manejo de la cancelación.
                } label: {
                    Text("Cancelar")
                }
            } message: { messageAutorizationTrackingAlert in
                Text(messageAutorizationTrackingAlert)
            }
            .alert(
                "Precisión Reducida",
                isPresented: $presentAccuracyTrackingAlert,
                presenting: messageAccuracyTrackingAlert // cambiar por el codigo de error
            ) { messageAccuracyTrackingAlert in
                
                Button("OK") {
                    presentAccuracyTrackingAlert = false
                    //locationManager.abrirConfiguracion()
                    locationManager.requestAccuracy { success, error_code, message in
                        // manejo de la respuesta
                        // volver a solicitar el metodo en caso de exito ??
                    }
                }
            } message: { messageAccuracyTrackingAlert in
                Text(messageAccuracyTrackingAlert)
            }
            .padding()
            
            // MARK: Iniciar Rastreo (precisa = true)
            Button {
                locationManager.iniciarRastreoUbicacionUsuario(precisa: true, propourseMessage: "rastreo") { success, location, error_code, message in
                    if success {
                        presentAutorizationTrackingAlert = false
                        
                        // Actualizar la posición de la cámara del mapa para centrarla alrededor de la ubicación del usuario
                        coordinateLocation = location
                        
                        if(withMap){
                            let regionSpan = MKCoordinateSpan(latitudeDelta: 0.125, longitudeDelta: 0.125)
                            mapRegion = MKCoordinateRegion(center: coordinateLocation!, span: regionSpan)
                            
                            //ios 17+
                            //self.position = .region(MKCoordinateRegion(center: coordinateLocation!, span: regionSpan))
                        }
                    }else{
                        
                        switch error_code {
                        case LocationManagerErorr.obtenerUbicacion.rawValue:
                            locationManager.checkAuthorization { success, error_code  in
                                if success == false {
                                    presentAutorizationTrackingAlert = true
                                    messageAutorizationTrackingAlert = message ?? "Tu ubicación actual no se puede determinar en este momento."
                                }else{
                                    presentAutorizationTrackingAlert = false
                                    //ocurrió otro error
                                }
                            }
                        case LocationManagerErorr.locationReducedAccuracy.rawValue:
                            presentAccuracyTrackingAlert = true
                            messageAccuracyTrackingAlert = "Tu ubicación actual no se puede determinar en este momento."
                        default:
                            return
                        }

                    }
                }
            } label: {
                Text("Iniciar Rastreo (precisa = true)")
            }
            .alert(
                "Ubicación no disponible",
                isPresented: $presentAutorizationTrackingAlert,
                presenting: messageAutorizationTrackingAlert // cambiar por el codigo de error
            ) { messageAutorizationTrackingAlert in
                
                Button("Ir a Configuración") {
                    locationManager.abrirConfiguracion()
                }
                
                Button(role: .cancel) {
                    // Manejo de la cancelación.
                } label: {
                    Text("Cancelar")
                }
            } message: { messageAutorizationTrackingAlert in
                Text(messageAutorizationTrackingAlert)
            }
            .alert(
                "Precisión Reducida",
                isPresented: $presentAccuracyTrackingAlert,
                presenting: messageAccuracyTrackingAlert // cambiar por el codigo de error
            ) { messageAccuracyTrackingAlert in
                
                Button("OK") {
                    presentAccuracyTrackingAlert = false
                    //locationManager.abrirConfiguracion()
                    locationManager.requestAccuracy { success, error_code, message in
                        // manejo de la respuesta
                        // volver a solicitar el metodo en caso de exito ??
                    }
                }
            } message: { messageAccuracyTrackingAlert in
                Text(messageAccuracyTrackingAlert)
            }
            .padding()
            
            Button {
                locationManager.detenerRastreoUbicacionUsuario { success, error_code, message in
                    // manejo de la respuesta
                }
            } label: {
                Text("Detener Rastreo")
            }
            .padding()

            Button {
                locationManager.abrirConfiguracion()
            } label: {
                Text("Configuración")
            }
            .padding()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
