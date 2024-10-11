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
    
    // MARK: Posición de la cámara del mapa
    //ios 17+
    //@State private var position: MapCameraPosition = .automatic
    @State var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.457105, longitude: -80.508361), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    var binding: Binding<MKCoordinateRegion> {
           Binding {
               self.mapRegion
           } set: { newRegion in
               self.mapRegion = newRegion
           }
       }
    
    @State private var presentAlert = false
    @State private var messageAlert = "Error"
    
    // MARK: Body
    var body: some View {
        VStack {
            // Mapa para visualizar la ubicación del Usuario
            /*Map(coordinateRegion: $mapRegion, showsUserLocation: true,userTrackingMode: .constant(.follow))
                            .edgesIgnoringSafeArea(.all)*/
            
            //ios 17+
            /*Map(position: $position) {
                UserAnnotation()
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))*/
                        
            Text("Latitud: \(self.coordinateLocation?.latitude ?? 0.0)")
                .foregroundColor(.secondary)
            
            Text("Longitud: \(self.coordinateLocation?.longitude ?? 0.0)")
                .foregroundColor(.secondary)

            Button {
                locationManager.obtenerUbicacionUsuario(precisa: true, propourseMessage: "Mensaje") { success, location, error_code, message in
                    if success {
                        presentAlert = false
                        // Actualizar la posición de la cámara del mapa para centrarla alrededor de la ubicación del usuario
                        
                        coordinateLocation = location
                        
                        let regionSpan = MKCoordinateSpan(latitudeDelta: 0.125, longitudeDelta: 0.125)
                        mapRegion = MKCoordinateRegion(center: coordinateLocation!, span: regionSpan)
                        
                        //ios 17+
                        //self.position = .region(MKCoordinateRegion(center: coordinateLocation!, span: regionSpan))
                    }else{
                        // Ocurrió un error al obtener la ubicación del usuario
                        locationManager.checkAuthorization { success in
                            if success == false {
                                presentAlert = true
                            }else{
                                presentAlert = false
                            }
                        }
                    }
                }
            } label: {
                Text("Obtener Ubicación")
            }
            .alert(
                "Ubicación no disponible",
                isPresented: $presentAlert,
                presenting: messageAlert
            ) { messageAlert in
                
                Button("Ir a Configuración") {
                    locationManager.abrirConfiguracion()
                }
                
                Button(role: .cancel) {
                    // Manejo de la cancelación.
                } label: {
                    Text("Cancelar")
                }
            } message: { messageAlert in
                // Se puede usar el mensaje de error que viene del metodo de obtenerUbicacionUsuario de la siguiente manera: Text(messageAlert)
                Text("Tu ubicación actual no se puede determinar en este momento."
                     + " Puedes abrir la configuración de la app para permitir el acceso a la ubicación.")
            }
            .padding()

            Button {
                locationManager.abrirConfiguracion()
            } label: {
                Text("Configuración")
            }
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
