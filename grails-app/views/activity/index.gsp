<g:applyLayout name="twoColumns">
    <head>
        <title>Lista de actividades</title>
    </head>

    <content tag="main">
        <g:render template="toolbar"/>

        <g:if test="${activityList}">
            <table class="table table-bordered table-hover">
                <col width="42%">
                <col width="5%">
                <col width="10%">
                <col width="10%">
                <col width="8%">
                <col width="10%">
                <col width="10%">
                <col width="5%">

                <thead>
                    <tr>
                        <th>Actividad</th>
                        <th class="text-center">Creado</th>
                        <th class="text-center">Notificado</th>
                        <th class="text-center">Confirmado</th>
                        <th class="text-center">Aprobado</th>
                        <th class="text-center">Autorizado</th>
                        <th class="text-center">Ubicaciones</th>
                        <th class="text-center">Vales</th>
                    </tr>
                </thead>

                <tbody>
                    <g:each in="${activityList}" var="activity">
                        <tr>
                            <td>
                                <g:link resource="employee/activity" action="show" id="${activity.id}" employeeId="${params.employeeId}"  method="GET">
                                    ${activity.name}
                                </g:link>
                            </td>
                            <td class="text-center" style="vertical-align: middle;">
                                <g:if test="${activity.state == 'created'}">
                                    <span class="glyphicon glyphicon-ok" aria-hidden="true"></span>
                                </g:if>
                            </td>
                            <td class="text-center" style="vertical-align: middle;">
                                <g:if test="${activity.state == 'notified'}">
                                    <span class="glyphicon glyphicon-ok" aria-hidden="true"></span>
                                </g:if>
                            </td>
                            <td class="text-center" style="vertical-align: middle;">
                                <g:if test="${activity.state == 'confirmed'}">
                                    <span class="glyphicon glyphicon-ok" aria-hidden="true"></span>
                                </g:if>
                            </td>
                            <td class="text-center" style="vertical-align: middle;">
                                <g:if test="${activity.state == 'approved'}">
                                    <span class="glyphicon glyphicon-ok" aria-hidden="true"></span>
                                </g:if>
                            </td>
                            <td class="text-center" style="vertical-align: middle;">
                                <g:if test="${activity.state == 'authorized'}">
                                    <span class="glyphicon glyphicon-ok" aria-hidden="true"></span>
                                </g:if>
                            </td>
                            <td class="text-center" style="vertical-align: middle;">
                                <g:link
                                    resource="employee/activity/location"
                                    action="index"
                                    params="[activityId: activity.id, employeeId: params.employeeId]"
                                    method="GET">${activity.locations ?: ''}</g:link>
                            </td>
                            <td class="text-center">
                                <g:link
                                    resource="employee/activity/voucher"
                                    action="index"
                                    params="[employeeId: params.employeeId, activityId: activity.id, type: 'employee']"
                                    method="GET">
                                    ${activity.vouchers}</g:link>
                            </td>
                        </tr>
                    </g:each>
                </tbody>
            </table>
        </g:if>
        <g:else>
            <p>Sin datos que mostrar</p>
        </g:else>
    </content>
</g:applyLayout>
