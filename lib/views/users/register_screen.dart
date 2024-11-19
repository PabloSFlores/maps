import 'package:maps_flutter/views/users/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:maps_flutter/viewmodels/auth_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}



class _RegisterScreenState extends State<RegisterScreen> {

  final passwordValidator = MultiValidator([
    RequiredValidator(errorText: 'La contraseña no debe ir vacia'),
    MinLengthValidator(8, errorText: 'La contraseña debe tener al menos 8 caracteres'),
    PatternValidator(r'^(?=\w*\d)(?=\w*[A-Z])(?=\w*[a-z])\S{8,16}$',errorText: 'La contraseña debe tener al entre 8 y 16 caracteres, al menos un dígito, al menos una minúscula y al menos una mayúscula.'),
  ]);

  final emailValidator = MultiValidator([
    RequiredValidator(errorText: 'El Correo es requerido'),
    EmailValidator(errorText: 'El texto del campo debe ser un Correo'),
  ]);

  final nameValidator = MultiValidator([
    RequiredValidator(errorText: 'El Nombre es requerido'),
    //PatternValidator(r'^[a-zA-Z]+$+/ /',errorText: 'El Nombre solo puede contener letras'),
    MinLengthValidator(10, errorText: 'El Nombre debe tener al menos 10 caracteres'),
  ]);


  final _formKey = GlobalKey<FormState>();
  //Definir los campos del formulario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Usuario'),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre Completo',),
                validator: nameValidator,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Correo Electronico',),
                validator: emailValidator,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: passwordValidator,
              ),
             SizedBox(height: 20),
              authViewModel.loading ?
                  CircularProgressIndicator()
                  : ElevatedButton(
                  onPressed: (){
                    if(_formKey.currentState!.validate()){
                      authViewModel.register(_nameController.text,_emailController.text,_passwordController.text).then(
                              (value) =>{
                            if(authViewModel.user!=null){
                              Navigator.popAndPushNamed(context, '/home')
                            }
                          }
                      );
                    }
                  }, 
                  child: Text('Registrarse')
              ),
              TextButton(
                  onPressed: (){
                    Navigator.popAndPushNamed(context, '/login');
                  },
                  child: Text('Ya tienes una cuenta?, Inicia Sesión')
              ),
              if(authViewModel.errorMessage!=null)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(authViewModel.errorMessage!,style: TextStyle(color: Colors.red),),
                )
            ],
          ),
        ),
      ),
    );
  }
}
