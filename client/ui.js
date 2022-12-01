/*
Archivo empleado para manejar las uncionalidades del forms y botones de la página web con Js
*/

// formulario de agregar dispositivo
const addForm = document.querySelector("#addForm");
const addLogin = document.querySelector("#login");

/* addForm.addEventListener("submit", e => {
    e.preventDefault(); // evita que la página recargue
    // almacenamos la data del forms 
    const id = addForm["id"].value;
    const nombre = addForm["nombre"].value;
    // la enviamos al contrato inteligente 
   App.agregarDispositivo(id, nombre);
}) */


addLogin.addEventListener("submit", e => {
    e.preventDefault();
    const matricula = addLogin["matricula"].value;
    const pass = addLogin["contrasena"].value;

    if(matricula && pass != null){
        if((matricula == null || !matricula) || (pass == null || !pass)){
            console.log("Debe completar los campos");
            } else {
              
            //enviando al contrato inteligente
            //console.log("Se han obtenido los siguientes datos: " + matricula + " " + pass)
            App.inicio_sesion(matricula, pass);
            }
    } else {
        console.log("Debe completar los campos");
    }
})











