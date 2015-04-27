# Ruby Multi-methods

Implementación de una extención al lenguaje Ruby para que este soporte métodos con definiciones parciales según el tipo de los parámetros con que se los llama

# Decisiones de diseño tomadas/ a discutir

1. Los Partial blocks son objetos Proc 
2. Cada vez que se hace una definicion de un nuevo multi method, se define un método con el símbolo indicado que al ser llamado delega la resolución de la ejecución en el multimethod
3. Los multimethods son objetos reificados con estado y comprotamiento propios
4. Los multimethods están en la definición de Module
5. Cada vez que se ejecuta un multimethod, se pasa la instancia por parámetro para que éste realice el instance eval
6. Los PartialBlocks saben calcular la distancia entre un argumento y un tipo de parámetro, auqnue esto rompa el encapsulamiento del argumento y pueda verse como un misplaced method. 

# Justificaciones

1. Esto permite  poder utilzarlos polimórficamente con cualquier otro bloque
2. Esto eprmite resolver el problema sin impactar en el modelo existente de Ruby
3. Porque son abstracciones necesarias del dominio
4. Porque deben poder aplicarse a módulos y clases por igual
5. Porque así se delega completamente en el objeto multimethod, que tiene sentido que sepa ejecutarse más allá de quien sea la instancia que lo ejecuta en ese momento.
6. Porque es una tarea que sólo necesitan los PartialBlocks, tal vez no sería conceptualmente correcto que todos los objetos sepan hacer esto

#Alternativas y comentarios
1. Que no lo sean y andar pidiéndoles el bloque
2. Toquetear la implementación de send para que sepa manejarse con multimethods
3. Usar un Hash
4. Meterlos en otro lado / Meterlos en un módulo "MultiMethodCapable" y luego hacer en Module el extends
5. que en el bloque pasado al define_method haga el instance eval y pida la definición(PartialBlock) que corresponde (Y la excepción que la tire... no sé dónde)
6. Que todos los objetos sepan calcular su distancia a un determinado ancestor. 


