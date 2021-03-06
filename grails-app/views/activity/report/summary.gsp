<g:applyLayout name="threeColumns">
    <head>
        <title>Resumen</title>
    </head>

    <content tag="main">
        <table class="table table-hover table-bordered">
            <col width="20%">
            <col width="10">
            <col width="10">
            <col width="10">
            <col width="10">
            <col width="10">
            <col width="10">
            <col width="10">
            <col width="10">

            <thead>
                <tr>
                    <th class="text-center">Mes</th>
                    <th class="text-center">Creado</th>
                    <th class="text-center">Notificado</th>
                    <th class="text-center">Confirmado</th>
                    <th class="text-center">Aprobado</th>
                    <th class="text-center">Autorizado</th>
                    <th class="text-center">Atendido</th>
                    <th class="text-center">Cancelado</th>
                    <th class="text-center">Total</th>
                </tr>
            </thead>

            <tbody>
                <g:each in="${results}" var="result">
                    <g:set var="p" value="${params.year ? [year: params.year, month: result.pivot] : [month: result.pivot]}"/>

                    <tr>
                        <td class="text-center">
                            <g:if test="${result.created || result.notified || result.confirmed || result.approved || result.authorized || result.attended || result.canceled}">
                                <g:link resource="activity" action="summaryReportDetail" params="${p}" method="GET">${result.month}</g:link>
                            </g:if>
                            <g:else>
                                ${result.month}
                            </g:else>
                        </td>
                        <td class="text-center">${result.created}</td>
                        <td class="text-center">${result.notified}</td>
                        <td class="text-center">${result.confirmed}</td>
                        <td class="text-center">${result.approved}</td>
                        <td class="text-center">${result.authorized}</td>
                        <td class="text-center">${result.attended}</td>
                        <td class="text-center">${result.canceled}</td>
                        <td class="text-center">${result.total}</td>
                    </tr>
                </g:each>
                <tr>
                    <td class="text-center">TOTAL</td>
                    <td class="text-center">${results.created.sum()}</td>
                    <td class="text-center">${results.notified.sum()}</td>
                    <td class="text-center">${results.confirmed.sum()}</td>
                    <td class="text-center">${results.approved.sum()}</td>
                    <td class="text-center">${results.authorized.sum()}</td>
                    <td class="text-center">${results.attended.sum()}</td>
                    <td class="text-center">${results.canceled.sum()}</td>
                    <td class="text-center">
                        <strong>${results.total.sum()}</strong>
                    </td>
                </tr>
            </tbody>
        </table>
    </content>

    <content tag="right">
        <g:render template="report/yearList"/>
    </content>
</g:applyLayout>
