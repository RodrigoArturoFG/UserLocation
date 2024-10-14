# UserLocation - Swift 5 - iOS 16.2+
# Clase capaz de gestionar la ubicación del usuario, así como gestionar los permisos necesarios.

Es necesario tener los mensajes correspondientes en el "Target Properties" del proyecto, para las keys correspondientes:  
  
<img width="1198" alt="Target Properties" src="https://github.com/user-attachments/assets/531c2be1-fe68-4608-8b96-948f95ba1800">  

En mi caso el Xcode: Version 14.2 (14C18) me crasheaba al agregar la key: "Privacy - Location Temporary Usage Description Dictionary", por lo que opte por agregarla en el info del proyecto:  
  
<img width="988" alt="Local Info" src="https://github.com/user-attachments/assets/ef4bbe9e-d362-4fde-8266-113c86a3f9d0">  

Para que se puedan visualizar las configuraciónes de la app, hay que agregar un paquete de Configuración al proyecto de iOS en Xcode:  
1.- Seleccionar File > New > New File  
2.- Ir a la sección de "Resource" de iOS  
3.- Seleccionar "Settings Bundle template"  
4.- Nombrar al archivo "Settings.bundle"  
  
<img width="736" alt="Resource iOS" src="https://github.com/user-attachments/assets/c41252e4-b186-4802-bb46-9c75900e72bf">

# Implementación SwiftUI

Para la implementación de la clase en una vista de SwiftUI, se tiene como ejemplo el archivo "ContentView" dentro del proyecto.  
  
Basicamente solo necesitamos de las siguientes variables para hacer uso de la clase:  
  
Instancia de LocationManager   
var locationManager = LocationManager()  
  
Variable para guardar la ubicación actual del usuario  
@State var coordinateLocation: CLLocationCoordinate2D?  
  
Variable para mostrar o no el Mapa en la Interfaz de Usuario  
@State var withMap = true  

Aunado a lo anterior, también necesitamos de darle un contexto a la llamada de los metodos.   
Para este ejemplo, se usaron unos botones para poder agregarles los mensajes que se mostraran al usuario como resultados de las respuestas de los metodos implementados.

Interfaz de usuario con Mapa:  
<img width="551" alt="Screen Shot 2024-10-14 at 12 14 44" src="https://github.com/user-attachments/assets/3544d7c8-099b-4381-a398-21e9a68ca2f9">  

Interfaz de usuario sin Mapa:  
<img width="551" alt="Screen Shot 2024-10-14 at 12 15 03" src="https://github.com/user-attachments/assets/2661aea0-e2ba-4155-b03c-390d138e2771">
    
# Metodos Públicos - LocationManager.swift
## Obtener la ubicación actual del usuario si está disponible  
func obtenerUbicacionUsuario(precisa:Bool, propourseMessage:String, completionHandler:@escaping (_ success:Bool, _ location:CLLocationCoordinate2D?, _ error_code: Int, _ message:String?) -> Void)   
Respuesta esperada: {success: Bool, location: CLLocationCoordinate2D, error_code: Int, message: String}
  
Este método debe encargarse de obtener la ubicación del usuario y devolverla a través del completion handler (callback). Si el usuario no tiene permitida la ubicación, se debe solicitar dicho permiso.  
Si el valor precisa es true, entonces se debe requerir al usuario la ubicación precisa de maner obligatoria  

## Iniciar un rastreo de la ubicación del usuario, devolviendo cada cierto tiempo la ubicación del usuario
func iniciarRastreoUbicacionUsuario(precisa:Bool, propourseMessage:String, completionHandler:@escaping (_ success:Bool, _ location:CLLocationCoordinate2D?, _ error_code: Int, _ message:String?) -> Void)  
Respuesta esperada: {success: Bool, location: CLLocationCoordinate2D, error_code: Int, message: String}  

Este método debe iniciar un rastreo de la ubicación del usuario, devolviendo cada cierto tiempo la ubicación del usuario. Si el usuario no tiene permitida la ubicación, se debe solicitar dicho permiso.  
Si el valor precisa es true, entonces se debe requerir al usuario la ubicación precisa de maner obligatoria. Se debe mostrar el indicador de que se esta realizando un rastreo de la ubicación.  

## Este método debe detener el rastreo de la ubicación  
func detenerRastreoUbicacionUsuario(completionHandler:@escaping (_ success:Bool, _ error_code: Int, _ message:String?)  
Respuesta esperada: {success: Bool, error_code: Int, message: String}  

Este método debe detener el rastreo de la ubicación del usuario  

## Ir a la configuración de la app  
func abrirConfiguracion()  

Este método se utilizará en caso de que el usuario denigue los permisos de ubicación, al ser llamado deberá abrir la configuración de la app para indicarle al usuario que permita el acceso a la ubicación.
