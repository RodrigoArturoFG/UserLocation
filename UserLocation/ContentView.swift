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
    
    // MARK: Propiedades
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
    
    // MARK: Body
    var body: some View {
        VStack {
            //ios 17+
            /*Map(position: $position) {
                UserAnnotation()
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))*/
            
            /*Map(coordinateRegion: $mapRegion, showsUserLocation: true,userTrackingMode: .constant(.follow))
                            .edgesIgnoringSafeArea(.all)*/
            
            Text("Latitud: \(self.coordinateLocation?.latitude ?? 0.0)")
                .foregroundColor(.secondary)
            
            Text("Longitud: \(self.coordinateLocation?.longitude ?? 0.0)")
                .foregroundColor(.secondary)

            
            Button {
                locationManager.obtenerUbicacionUsuario(precisa: true, propourseMessage: "cualquier cosa") { success, location, error_code, message in
                    if success {
                        coordinateLocation = location
                        
                        // Update the camera position of the map to center around the user location
                        let regionSpan = MKCoordinateSpan(latitudeDelta: 0.125, longitudeDelta: 0.125)
                        mapRegion = MKCoordinateRegion(center: coordinateLocation!, span: regionSpan)
                        
                        //ios 17+
                        //self.position = .region(MKCoordinateRegion(center: coordinateLocation!, span: regionSpan))
                        print("Nuevo metodo: \(String(describing: self.coordinateLocation) )")
                    }
                }
            } label: {
                Text("Get Location")
            }
                .padding()

            Button {
                locationManager.abrirConfiguracion()
            } label: {
                Text("Settings")
            }
            
        }
        .padding()
        .task {
            // Comprueba si la aplicación está autorizada para acceder a los servicios de ubicación del dispositivo
            locationManager.checkAuthorization()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
