<g:applyLayout name="twoColumns">
    <head>
        <title>Logistica semanal</title>
    </head>

    <content tag="main">
        <g:render template="toolbar"/>

        <g:if test="${results}">
                <table class="table table-hover">
                    <col width="20%">
                    <col width="80%">

                    <tbody>
                        <g:each in="${results}" var="result">
                            <tr>
                                <td colspan="2">
                                    <b>${result.date}</b>
                                </td>
                            </tr>

                            <g:each in="${result.locations}" var="location">
                                <tr>
                                    <td colspan="2">
                                        <b>${location.name}</b>
                                    </td>
                                </tr>

                                <tr>
                                    <td>Aula</td>
                                    <td>${location.place}</td>
                                </tr>

                                <tr>
                                    <td>Horario</td>
                                    <td>${location.startTime} a ${location.endTime}</td>
                                </tr>

                                <tr>
                                    <td>Participantes</td>
                                    <td>${location.participants}</td>
                                </tr>

                                <g:if test="${params.type == 'concierge'}">
                                    <tr>
                                        <td>Tipo de montaje</td>
                                        <td>${location.typeOfAssembly}</td>
                                    </tr>
                                </g:if>

                                <g:if test="${params.type == 'protocol'}">
                                    <tr>
                                        <td>Manteleria</td>
                                        <td>
                                            <g:join in="${location.tableLinen}"/>
                                        </td>
                                    </tr>

                                    <g:if test="${location.waterBottles}">
                                        <tr>
                                            <td>Botellas de agua</td>
                                            <td>${location.waterBottles}</td>
                                        </tr>
                                    </g:if>

                                    <g:if test="${location.quantity}">
                                        <tr>
                                            <td>Cantidad de refrigerios</td>
                                            <td>${location.quantity}</td>
                                        </tr>
                                    </g:if>
                                </g:if>

                                <tr>
                                    <td>Requerimientos</td>
                                    <td>
                                        <g:join in="${location.requirements}"/>
                                    </td>
                                </tr>
                            </g:each>
                        </g:each>
                    </tbody>
                </table>

            <g:link
                resource="employee/activity"
                action="printWeeklyLogistics"
                params="[employeeId: params.employeeId, type: params.type]"
                method="GET"
                class="btn btn-primary">Imprimir</g:link>
        </g:if>
        <g:else>
            <p>Sin datos que mostrar</p>
        </g:else>
    </content>
</g:applyLayout>
