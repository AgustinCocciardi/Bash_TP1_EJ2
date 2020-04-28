#!/bin/bash

cd "$2"

archivos=$( find -maxdepth 1 -name "*.log")

for archivo in $archivos
do
    declare -A Dias
    declare -A DuracionXDia
    declare -A LlamadasPorDia

    declare -A Usuarios
    declare -A LlamadasPorSemana

    declare -A masLlamadasPorSemana

    declare -a array
    i=0

    a=0
    
    echo "SEMANA"
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

    echo "Duración promedio de llamadas por dia"
    for dia in ${Dias[@]}
    do
        promedioDiario=$((${DuracionXDia[$dia]}/${LlamadasPorDia[$dia]}))
        echo "El promedio de llamadas en el dia $dia es: $promedioDiario"
    done

    echo 
    echo "Los 3 usuarios con mas llamada por semana"
    for usuar in ${masLlamadasPorSemana[@]}
    do
        echo $usuar
    done

    echo "---"
    echo
    
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
done