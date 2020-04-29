#!/bin/bash

#Funcion que muestra la ayuda
function ayuda(){
    echo "Este script se ha creado con la finalidad de analizar archivos de log de llamadas que se encuentran en un directorio"
    echo "Se procesarán los archivos y por cada uno se mostrará por pantalla lo siguiente:"
    echo "Promedio de tiempo de llamadas realizada por día"
    echo "Promedio de tiempo y cantidad por usuario por día"
    echo "Los 3 usuarios con más llamadas en la semana"
    echo "Cuantas llamadas no superan la media de tiempo por día y el usuario que tiene más llamadas por debajo de la media en la semana"
    echo "Ejecución del script"
    echo "./TP1EJ2.sh -f 'path_de_los_archivos_de_log'"
    echo "El path_de_los_archivos_de_log puede ser absoluto o relativo"
    echo "ACLARACIÓN IMPORTANTE: El promedio de las llamadas se mide en segundos"
	exit 0
} 

#Funcion que me hace salir del script si los parámetros no son correctos
function salir1(){
    echo "El numero de parametros no es correcto"
    echo "Ingrese './TP1EJ2.sh -h' O './TP1EJ2.sh -?' O './TP1EJ2.sh -help' para ver la ayuda"
    exit 1
}

#Funcion que me hace salir del script si la ruta de archivos de log ingresada no es válida
function salir2(){
    echo "La ruta de los archivos de Log no es un directorio VALIDO";
	exit 2;
}

#Funcion que me hace salir del script si la ruta de archivos de log ingresada está vacía
function salir3(){
    echo "No hay archivos en el directorio que usted pasó por parámetro";
	exit 3;
}

#Verifico si el usuario quiere ver la ayuda
if [ $1 = "-h" -o $1 = "-?" -o $1 = "-help" ]
then
	ayuda
fi

#valido que el numero de parametro sea correcto
if [ $# -ne 2 ]; then
    salir1
fi

#valido que las letras sean correctas que pase como parámetro sean correctas
if [ $1 != "-f" ]; then
    echo "El primer parámetro debe ser '-f'"
    exit 100
fi

#valido que la ruta donde están los archivos de log sea un directorio valido
if [ ! -d "$2" ] 
then
	salir2
fi

#valido que la ruta donde están los archivos de log contenga archivos
dato=$(ls -1 "$2" | wc -l)

if [ "$dato" -eq 0 ] 
then
	salir3
fi

cd "$2"

archivos=$( find -maxdepth 1 -name "*.log")

for archivo in $archivos
do
    #Arrays para resolver el promedio diario
    declare -A Dias
    declare -A DuracionXDia
    declare -A LlamadasPorDia

    #Arrays para resolver a los usuarios con más llamadas por semana
    declare -A Usuarios
    declare -A LlamadasPorSemana
    declare -A masLlamadasPorSemana

    #Arrays (y variables) para resolver cantidad de llamadas y promedio por dia por usuario
    diaActual=0                       #Me indica el día en el que estoy y qué vector debo usar
    declare -A LlamadasUsuarioPorDia1 #Me indica la cantidad de llamadas de usuario en el día 1
    declare -A LlamadasUsuarioPorDia2 #Me indica la cantidad de llamadas de usuario en el día 2
    declare -A LlamadasUsuarioPorDia3 #Me indica la cantidad de llamadas de usuario en el día 3
    declare -A LlamadasUsuarioPorDia4 #Me indica la cantidad de llamadas de usuario en el día 4
    declare -A LlamadasUsuarioPorDia5 #Me indica la cantidad de llamadas de usuario en el día 5
    declare -A LlamadasUsuarioPorDia6 #Me indica la cantidad de llamadas de usuario en el día 6
    declare -A LlamadasUsuarioPorDia7 #Me indica la cantidad de llamadas de usuario en el día 7
    declare -A DuracionUsuarioPorDia1 #Me indica la duración de llamadas de usuario en el día 1
    declare -A DuracionUsuarioPorDia2 #Me indica la duración de llamadas de usuario en el día 2
    declare -A DuracionUsuarioPorDia3 #Me indica la duración de llamadas de usuario en el día 3
    declare -A DuracionUsuarioPorDia4 #Me indica la duración de llamadas de usuario en el día 4
    declare -A DuracionUsuarioPorDia5 #Me indica la duración de llamadas de usuario en el día 5
    declare -A DuracionUsuarioPorDia6 #Me indica la duración de llamadas de usuario en el día 6
    declare -A DuracionUsuarioPorDia7 #Me indica la duración de llamadas de usuario en el día 7

    #Arrays para resolver cuantas llamadas no superan la media de tiempo por día
    cantidadLlamadasDia1=0          #Me indica cuantas llamadas se hicieron en el día 1
    declare -A DuracionLlamadasDia1 #Me indica la duración de cada llamada hecha en el día 1
    cantidadLlamadasDia2=0          #Me indica cuantas llamadas se hicieron en el día 2
    declare -A DuracionLlamadasDia2 #Me indica la duración de cada llamada hecha en el día 2
    cantidadLlamadasDia2=0          #Me indica cuantas llamadas se hicieron en el día 2
    declare -A DuracionLlamadasDia2 #Me indica la duración de cada llamada hecha en el día 2
    cantidadLlamadasDia3=0          #Me indica cuantas llamadas se hicieron en el día 3
    declare -A DuracionLlamadasDia3 #Me indica la duración de cada llamada hecha en el día 3
    cantidadLlamadasDia4=0          #Me indica cuantas llamadas se hicieron en el día 4
    declare -A DuracionLlamadasDia4 #Me indica la duración de cada llamada hecha en el día 4
    cantidadLlamadasDia5=0          #Me indica cuantas llamadas se hicieron en el día 5
    declare -A DuracionLlamadasDia5 #Me indica la duración de cada llamada hecha en el día 5
    cantidadLlamadasDia6=0          #Me indica cuantas llamadas se hicieron en el día 6
    declare -A DuracionLlamadasDia6 #Me indica la duración de cada llamada hecha en el día 6
    cantidadLlamadasDia7=0          #Me indica cuantas llamadas se hicieron en el día 7
    declare -A DuracionLlamadasDia7 #Me indica la duración de cada llamada hecha en el día 7


    declare -a array
    i=0

    a=0
    
    echo "Archivo: $archivo"
    inicio=$a
    contadorDias=0
    contadorUsuarios=0
    while IFS="\n" read -r line
    do
        array[$i]+=$line
        let "i++"
    done < $archivo

    while [[ ! -z "${array[$a]}" ]]
    do
        #echo ${array[$a]}
        let "a++"
    done
    final=$a
    #echo "Terminé de contar $final registros y voy a procesarlos"
    #sleep 1
    procesados=1
    llamadaIniciada=0
    while [ $procesados -eq 1 ]
    do
        if [ $llamadaIniciada -eq 0 ];then
            llamadaIniciada=1
            #echo "Estoy buscando el inicio de la llamada"
            #sleep 2
            empieza=$inicio
            termina=$final
            while [ $empieza -lt $termina ]
            do
            #registroTomado=${array[$empieza]}
            #echo "Tome el registro $registroTomado"
            #sleep 2
                if [ "${array[$empieza]}" != "0" ];then
                #echo "Voy  ${array[$empieza]}"
                #sleep 1
                    IFS=' ' read -r -a nuevoArray <<< "${array[$empieza]}"
                    array[$empieza]=0
                    dia=${nuevoArray[0]}
                    hora=${nuevoArray[1]}
                    usuario=${nuevoArray[3]}
                    empieza=$termina
                else
                    let "empieza++"
                fi
            done

            #echo "El dia es: $dia"     
            diaAgregado=1
            for i in ${Dias[@]}
                do
                    if [ "$i" == $dia ];then
                        diaAgregado=0
                    fi
                done
            
            if [ $diaAgregado -eq 1 ];then
                #echo "El dìa $dia todavìa no está en el vector de días"
                #sleep 2
                Dias[$contadorDias]=$dia
                DuracionXDia[$dia]=0
                LlamadasPorDia[$dia]=0
                let "contadorDias++"
                let "diaActual++"
            fi
            
            IFS=': ' read -r -a tiempo <<< "$hora"
            hour=$((${tiempo[0]}*3600))
            minute=$((${tiempo[1]}*60))
            second=${tiempo[2]}
            duracion=$(($hour+$minute+$second))
            DuracionXDia[$dia]=$((${DuracionXDia[$dia]}-$duracion))

            #echo "Usuario: $usuario"
            #sleep 2
            
            usuarioAgregado=1
            for i in ${Usuarios[@]}
            do
                if [ "$i" == $usuario ];then
                    usuarioAgregado=0
                fi
            done
            if [ $usuarioAgregado -eq 1 ];then
                Usuarios[$contadorUsuarios]=$usuario
                LlamadasPorSemana[$usuario]=0
                let "contadorUsuarios++"
                LlamadasUsuarioPorDia1[$usuario]=0
                LlamadasUsuarioPorDia2[$usuario]=0
                LlamadasUsuarioPorDia3[$usuario]=0
                LlamadasUsuarioPorDia4[$usuario]=0
                LlamadasUsuarioPorDia5[$usuario]=0
                LlamadasUsuarioPorDia6[$usuario]=0
                LlamadasUsuarioPorDia7[$usuario]=0
                DuracionUsuarioPorDia1[$usuario]=0
                DuracionUsuarioPorDia2[$usuario]=0
                DuracionUsuarioPorDia3[$usuario]=0
                DuracionUsuarioPorDia4[$usuario]=0
                DuracionUsuarioPorDia5[$usuario]=0
                DuracionUsuarioPorDia6[$usuario]=0
                DuracionUsuarioPorDia7[$usuario]=0
            fi

            if [ $diaActual -eq 1 ];then
                DuracionUsuarioPorDia1[$usuario]=$((${DuracionUsuarioPorDia1[$usuario]}-$duracion))
                DuracionLlamadasDia1[$cantidadLlamadasDia1]=$((0-$duracion))
            elif [ $diaActual -eq 2 ];then
                DuracionUsuarioPorDia2[$usuario]=$((${DuracionUsuarioPorDia2[$usuario]}-$duracion))
                DuracionLlamadasDia2[$cantidadLlamadasDia2]=$((0-$duracion))
            elif [ $diaActual -eq 3 ];then
                DuracionUsuarioPorDia3[$usuario]=$((${DuracionUsuarioPorDia3[$usuario]}-$duracion))
                DuracionLlamadasDia3[$cantidadLlamadasDia3]=$((0-$duracion))
            elif [ $diaActual -eq 4 ];then
                DuracionUsuarioPorDia4[$usuario]=$((${DuracionUsuarioPorDia4[$usuario]}-$duracion))
                DuracionLlamadasDia4[$cantidadLlamadasDia4]=$((0-$duracion))
            elif [ $diaActual -eq 5 ];then
                DuracionUsuarioPorDia5[$usuario]=$((${DuracionUsuarioPorDia5[$usuario]}-$duracion))
                DuracionLlamadasDia5[$cantidadLlamadasDia5]=$((0-$duracion))
            elif [ $diaActual -eq 6 ];then
                DuracionUsuarioPorDia6[$usuario]=$((${DuracionUsuarioPorDia6[$usuario]}-$duracion))
                DuracionLlamadasDia6[$cantidadLlamadasDia6]=$((0-$duracion))
            else
                DuracionUsuarioPorDia7[$usuario]=$((${DuracionUsuarioPorDia7[$usuario]}-$duracion))
                DuracionLlamadasDia7[$cantidadLlamadasDia7]=$((0-$duracion))
            fi
        fi

        if [ $llamadaIniciada -eq 1 ];then
            llamadaIniciada=0
            #echo "Estoy buscando el fin de la llamada"
            #sleep 2
            empieza=$inicio
            termina=$final
            while [ $empieza -lt $termina ]
            do
                if [ "${array[$empieza]}" != "0" ];then
                #registroTomado=${array[$empieza]}
                #echo "Tomè el registro numero $empieza: $registroTomado"
                #sleep 2
                    IFS=' ' read -r -a nuevoArray <<< "${array[$empieza]}"
                    nuevoUser=${nuevoArray[3]}
                    #echo "Comparo $usuario con $nuevoUser"
                    #sleep 1
                    if [ "$usuario" == "$nuevoUser" ];then
                        #echo "Son iguales"
                        #sleep 1
                        array[$empieza]=0
                        empieza=$termina
                        nuevoDia=${nuevoArray[0]}
                        nuevaHora=${nuevoArray[1]}
                        IFS=':' read -r -a tiempo <<< "$nuevaHora"
                        hour=$((${tiempo[0]}*3600))
                        minute=$((${tiempo[1]}*60))
                        second=${tiempo[2]}
                        duracion=$(($hour+$minute+$second))
                        DuracionXDia[$dia]=$((${DuracionXDia[$dia]}+$duracion))
                        LlamadasPorDia[$dia]=$((${LlamadasPorDia[$dia]}+1))
                        LlamadasPorSemana[$nuevoUser]=$((${LlamadasPorSemana[$nuevoUser]}+1))
                        #echo "Dìa: $diaActual"
                        #sleep 2
                        if [ $diaActual -eq 1 ];then
                            LlamadasUsuarioPorDia1[$nuevoUser]=$((${LlamadasUsuarioPorDia1[$nuevoUser]}+1))
                            DuracionUsuarioPorDia1[$nuevoUser]=$((${DuracionUsuarioPorDia1[$nuevoUser]}+$duracion))
                            DuracionLlamadasDia1[$cantidadLlamadasDia1]=$((${DuracionLlamadasDia1[$cantidadLlamadasDia1]}+$duracion))
                            #echo "Duración de llamada: ${DuracionLlamadasDia1[$cantidadLlamadasDia1]}"
                            #sleep 4
                            let "cantidadLlamadasDia1++"
                            #echo "Cantidad llamadas en día 1 hasta ahora: $cantidadLlamadasDia1"
                            #sleep 3
                            #echo "$nuevoUser: Llamadas:${LlamadasUsuarioPorDia1[$nuevoUser]} <--> Duracion: ${DuracionUsuarioPorDia1[$nuevoUser]}"
                            #sleep 3
                        elif [ $diaActual -eq 2 ];then
                            LlamadasUsuarioPorDia2[$nuevoUser]=$((${LlamadasUsuarioPorDia2[$nuevoUser]}+1))
                            DuracionUsuarioPorDia2[$nuevoUser]=$((${DuracionUsuarioPorDia2[$nuevoUser]}+$duracion))
                            DuracionLlamadasDia2[$cantidadLlamadasDia2]=$((${DuracionLlamadasDia2[$cantidadLlamadasDia2]}+$duracion))
                            let "cantidadLlamadasDia2++"
                            #echo "$nuevoUser: Llamadas:${LlamadasUsuarioPorDia2[$nuevoUser]} <--> Duracion: ${DuracionUsuarioPorDia2[$nuevoUser]}"
                            #sleep 3
                        elif [ $diaActual -eq 3 ];then
                            LlamadasUsuarioPorDia3[$nuevoUser]=$((${LlamadasUsuarioPorDia3[$nuevoUser]}+1))
                            DuracionUsuarioPorDia3[$nuevoUser]=$((${DuracionUsuarioPorDia3[$nuevoUser]}+$duracion))
                            DuracionLlamadasDia3[$cantidadLlamadasDia3]=$((${DuracionLlamadasDia3[$cantidadLlamadasDia3]}+$duracion))
                            let "cantidadLlamadasDia3++"
                        elif [ $diaActual -eq 4 ];then
                            LlamadasUsuarioPorDia4[$nuevoUser]=$((${LlamadasUsuarioPorDia4[$nuevoUser]}+1))
                            DuracionUsuarioPorDia4[$nuevoUser]=$((${DuracionUsuarioPorDia4[$nuevoUser]}+$duracion))
                            DuracionLlamadasDia4[$cantidadLlamadasDia4]=$((${DuracionLlamadasDia4[$cantidadLlamadasDia4]}+$duracion))
                            let "cantidadLlamadasDia4++"
                        elif [ $diaActual -eq 5 ];then
                            LlamadasUsuarioPorDia5[$nuevoUser]=$((${LlamadasUsuarioPorDia5[$nuevoUser]}+1))
                            DuracionUsuarioPorDia5[$nuevoUser]=$((${DuracionUsuarioPorDia5[$nuevoUser]}+$duracion))
                            DuracionLlamadasDia5[$cantidadLlamadasDia5]=$((${DuracionLlamadasDia5[$cantidadLlamadasDia5]}+$duracion))
                            let "cantidadLlamadasDia5++"
                        elif [ $diaActual -eq 6 ];then
                            LlamadasUsuarioPorDia6[$nuevoUser]=$((${LlamadasUsuarioPorDia6[$nuevoUser]}+1))
                            DuracionUsuarioPorDia6[$nuevoUser]=$((${DuracionUsuarioPorDia6[$nuevoUser]}+$duracion))
                            DuracionLlamadasDia6[$cantidadLlamadasDia6]=$((${DuracionLlamadasDia6[$cantidadLlamadasDia6]}+$duracion))
                            let "cantidadLlamadasDia6++"
                        else
                            LlamadasUsuarioPorDia7[$nuevoUser]=$((${LlamadasUsuarioPorDia7[$nuevoUser]}+1))
                            DuracionUsuarioPorDia7[$nuevoUser]=$((${DuracionUsuarioPorDia7[$nuevoUser]}+$duracion))
                            DuracionLlamadasDia7[$cantidadLlamadasDia7]=$((${DuracionLlamadasDia7[$cantidadLlamadasDia7]}+$duracion))
                            let "cantidadLlamadasDia7++"
                        fi
                    else
                        #echo "No son iguales"
                        #sleep 1
                        let "empieza++"
                    fi
                else
                    let "empieza++"
                fi
            done

            #echo "Reviso que haya terminado de procesar"
            empieza=$inicio
            termina=$final
            procesados=0
            while [ $empieza -lt $termina ]
            do
                if [ "${array[$empieza]}" != "0" ];then
                    procesados=1
                    #echo "Todavia no terminé de procesar"
                    #sleep 1
                    empieza=$termina
                else
                    let "empieza++"
                fi
            done
        fi

    done
    #echo "Termine de procesar los registros"

    insercion=0
    for (( c=1; c<=3; c++))
    do
        mayor=0
        for user in ${Usuarios[@]}
        do
            if [ ${LlamadasPorSemana[$user]} -gt $mayor ];then
                mayor=${LlamadasPorSemana[$user]}
                userMayor=$user
            fi
        done
        masLlamadasPorSemana[$insercion]+=$userMayor
        let "insercion++"
        LlamadasPorSemana[$userMayor]=0
    done

    #Este bloque muestra el promedio de llamadas por día
    echo "Duración promedio de llamadas por dia"
    for dia in ${Dias[@]}
    do
        promedioDiario=$((${DuracionXDia[$dia]}/${LlamadasPorDia[$dia]}))
        echo "El promedio de llamadas en el dia $dia es: $promedioDiario"
    done

    echo 

    #Este bloque muestra la cantidad y el promedio por día por usuario
    echo "Cantidad y promedio por usuario por día:"
    for users in ${Usuarios[@]}
    do
        if [ $diaActual -ge 1 ];then
            diAct=0
            if [ ${LlamadasUsuarioPorDia1[$users]} -ne 0 ];then
                average=$((${DuracionUsuarioPorDia1[$users]}/${LlamadasUsuarioPorDia1[$users]}))
                echo "$users cantidad de llamadas: ${LlamadasUsuarioPorDia1[$users]} . Promedio: $average. Día ${Dias[$diAct]}"
            else
                echo "$users no hizo llamadas en el día ${Dias[$diAct]}"
            fi
        fi
        if [ $diaActual -ge 2 ];then
            diAct=1
            if [ ${LlamadasUsuarioPorDia2[$users]} -ne 0 ];then
                average=$((${DuracionUsuarioPorDia2[$users]}/${LlamadasUsuarioPorDia2[$users]}))
                echo "$users cantidad de llamadas: ${LlamadasUsuarioPorDia2[$users]} . Promedio: $average. Día ${Dias[$diAct]}"
            else
                echo "$users no hizo llamadas en el día ${Dias[$diAct]}"
            fi
        fi
        if [ $diaActual -ge 3 ];then
            diAct=2
            if [ ${LlamadasUsuarioPorDia3[$users]} -ne 0 ];then
                average=$((${DuracionUsuarioPorDia3[$users]}/${LlamadasUsuarioPorDia3[$users]}))
                echo "$users cantidad de llamadas: ${LlamadasUsuarioPorDia3[$users]} . Promedio: $average. Día ${Dias[$diAct]}"
            else
                echo "$users no hizo llamadas en el día ${Dias[$diAct]}"
            fi
        fi
        if [ $diaActual -ge 4 ];then  
            diAct=3
            if [ ${LlamadasUsuarioPorDia4[$users]} -ne 0 ];then
                average=$((${DuracionUsuarioPorDia4[$users]}/${LlamadasUsuarioPorDia4[$users]}))
                echo "$users cantidad de llamadas: ${LlamadasUsuarioPorDia4[$users]} . Promedio: $average. Día ${Dias[$diAct]}"
            else
                echo "$users no hizo llamadas en el día ${Dias[$diAct]}"
            fi
        fi
        if [ $diaActual -ge 5 ];then
            diAct=4
            if [ ${LlamadasUsuarioPorDia5[$users]} -ne 0 ];then
                average=$((${DuracionUsuarioPorDia5[$users]}/${LlamadasUsuarioPorDia5[$users]}))
                echo "$users cantidad de llamadas: ${LlamadasUsuarioPorDia5[$users]} . Promedio: $average. Día ${Dias[$diAct]}"
            else
                echo "$users no hizo llamadas en el día ${Dias[$diAct]}"
            fi
        fi
        if [ $diaActual -ge 6 ];then
            diAct=5
            if [ ${LlamadasUsuarioPorDia6[$users]} -ne 0 ];then
                average=$((${DuracionUsuarioPorDia6[$users]}/${LlamadasUsuarioPorDia6[$users]}))
                echo "$users cantidad de llamadas: ${LlamadasUsuarioPorDia6[$users]} . Promedio: $average. Día ${Dias[$diAct]}"
            else
                echo "$users no hizo llamadas en el día ${Dias[$diAct]}"
            fi
        fi
        if [ $diaActual -ge 7 ];then
            diAct=6
            if [ ${LlamadasUsuarioPorDia7[$users]} -ne 0 ];then
                average=$((${DuracionUsuarioPorDia7[$users]}/${LlamadasUsuarioPorDia7[$users]}))
                echo "$users cantidad de llamadas: ${LlamadasUsuarioPorDia7[$users]} . Promedio: $average. Día ${Dias[$diAct]}"
            else
                echo "$users no hizo llamadas en el día ${Dias[$diAct]}"
            fi
        fi
    done

    echo

    #Este bloque muestra a los 3 usuarios con más llamadas por semana
    echo "Los 3 usuarios con mas llamada por semana"
    for usuar in ${masLlamadasPorSemana[@]}
    do
        echo $usuar
    done

    echo

    #Este bloque muestra la cantidad de llamadas que no superan la media de tiempo por día
    echo "Cantidad de llamadas que no superan la media de tiempo por día"
    diaEnElQueEstoyActualmente=1
    for day in ${Dias[@]}
    do
        numeroTotalDeLlamadas=0
        if [ $diaEnElQueEstoyActualmente -eq 1 ];then
            promedioDiario=$((${DuracionXDia[$dia]}/${LlamadasPorDia[$dia]}))
            #echo "Promedio diario: $promedioDiario"
            #sleep 3
            for call in ${DuracionLlamadasDia1[@]}
            do
                #echo "$call <---> $promedioDiario"
                #sleep 3
                if [ $call -lt $promedioDiario ];then
                    let "numeroTotalDeLlamadas++"
                fi
            done
            echo "En el día $day se hicieron $numeroTotalDeLlamadas llamada(s) que no superan el promedio diario"
        fi
        if [ $diaEnElQueEstoyActualmente -eq 2 ];then
            promedioDiario=$((${DuracionXDia[$dia]}/${LlamadasPorDia[$dia]}))
            for call in ${DuracionLlamadasDia2[@]}
            do
                if [ $call -lt $promedioDiario ];then
                    let "numeroTotalDeLlamadas++"
                fi
            done
            echo "En el día $day se hicieron $numeroTotalDeLlamadas llamada(s) que no superan el promedio diario"
        fi
        if [ $diaEnElQueEstoyActualmente -eq 3 ];then
            promedioDiario=$((${DuracionXDia[$dia]}/${LlamadasPorDia[$dia]}))
            for call in ${DuracionLlamadasDia3[@]}
            do
                if [ $call -lt $promedioDiario ];then
                    let "numeroTotalDeLlamadas++"
                fi
            done
            echo "En el día $day se hicieron $numeroTotalDeLlamadas llamada(s) que no superan el promedio diario"
        fi
        if [ $diaEnElQueEstoyActualmente -eq 4 ];then
            promedioDiario=$((${DuracionXDia[$dia]}/${LlamadasPorDia[$dia]}))
            for call in ${DuracionLlamadasDia4[@]}
            do
                if [ $call -lt $promedioDiario ];then
                    let "numeroTotalDeLlamadas++"
                fi
            done
            echo "En el día $day se hicieron $numeroTotalDeLlamadas llamada(s) que no superan el promedio diario"
        fi
        if [ $diaEnElQueEstoyActualmente -eq 5 ];then
            promedioDiario=$((${DuracionXDia[$dia]}/${LlamadasPorDia[$dia]}))
            for call in ${DuracionLlamadasDia5[@]}
            do
                if [ $call -lt $promedioDiario ];then
                    let "numeroTotalDeLlamadas++"
                fi
            done
            echo "En el día $day se hicieron $numeroTotalDeLlamadas llamada(s) que no superan el promedio diario"
        fi
        if [ $diaEnElQueEstoyActualmente -eq 6 ];then
            promedioDiario=$((${DuracionXDia[$dia]}/${LlamadasPorDia[$dia]}))
            for call in ${DuracionLlamadasDia6[@]}
            do
                if [ $call -lt $promedioDiario ];then
                    let "numeroTotalDeLlamadas++"
                fi
            done
            echo "En el día $day se hicieron $numeroTotalDeLlamadas llamada(s) que no superan el promedio diario"
        fi
        if [ $diaEnElQueEstoyActualmente -eq 7 ];then
            promedioDiario=$((${DuracionXDia[$dia]}/${LlamadasPorDia[$dia]}))
            for call in ${DuracionLlamadasDia7[@]}
            do
                if [ $call -lt $promedioDiario ];then
                    let "numeroTotalDeLlamadas++"
                fi
            done
            echo "En el día $day se hicieron $numeroTotalDeLlamadas llamada(s) que no superan el promedio diario"
        fi
        let "diaEnElQueEstoyActualmente++"
    done

    echo "[*****************************************************************************************************************]"
    
    unset hour
    unset minute
    unset second
    unset duracion
    unset dia
    unset hora
    unset usuario
    unset usuarioAgregado
    unset contadorUsuarios
    unset llamadaIniciada
    unset nuevoUser
    unset nuevoDia
    unset nuevaHora
    unset hour
    unset minute
    unset second
    unset insercion
    unset mayor
    unset userMayor
    unset usuar
    unset inicio
    unset final
    unset empieza
    unset termina
    unset Dias
    unset DuracionXDia
    unset promedio
    unset promedioDiario
    unset Usuarios
    unset LlamadasPorDia
    unset masLlamadasPorSemana
    unset procesados
    unset archivo
    unset diaActual
    unset DuracionUsuarioPorDia1
    unset DuracionUsuarioPorDia2
    unset DuracionUsuarioPorDia3
    unset DuracionUsuarioPorDia4
    unset DuracionUsuarioPorDia5
    unset DuracionUsuarioPorDia6
    unset DuracionUsuarioPorDia7
    unset LlamadasUsuarioPorDia1
    unset LlamadasUsuarioPorDia2
    unset LlamadasUsuarioPorDia3
    unset LlamadasUsuarioPorDia4
    unset LlamadasUsuarioPorDia5
    unset LlamadasUsuarioPorDia6
    unset LlamadasUsuarioPorDia7
    unset users
    unset average
    unset diAct
    unset cantidadLlamadasDia1
    unset cantidadLlamadasDia2
    unset cantidadLlamadasDia3
    unset cantidadLlamadasDia4
    unset cantidadLlamadasDia5
    unset cantidadLlamadasDia6
    unset cantidadLlamadasDia7
    unset DuracionLlamadasDia1
    unset DuracionLlamadasDia2
    unset DuracionLlamadasDia3
    unset DuracionLlamadasDia4
    unset DuracionLlamadasDia5
    unset DuracionLlamadasDia6
    unset DuracionLlamadasDia7
    unset diaEnElQueEstoyActualmente
    unset numeroTotalDeLlamadas
done