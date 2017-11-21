<div class="clearfix">
    <div class="pull-right">
        <sec:ifAnyGranted roles='ROLE_COORDINATOR, ROLE_ACADEMIC_COORDINATOR, ROLE_ADMINISTRATIVE_COORDINATOR, ROLE_PROTOCOL'>
            <g:link
                resource="employee/activity"
                action="requiringAttention"
                params="[employeeId: params.employeeId]"
                class="btn btn-default ${actionName == 'requiringAttention' ? 'active' : ''}">
                Notificaciones <span class="label label-info">${toolbar.notificationNumber ?: null}</span>
            </g:link>
        </sec:ifAnyGranted>

        <sec:ifAnyGranted roles="ROLE_PROTOCOL">
            <div class="btn-group">
                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    Logistica semanal <span class="caret"></span>
                </button>

                <ul class="dropdown-menu" aria-labelledby="dropdownMenu1">
                    <g:each in="${toolbar.logisticsTypeList}" var="type">
                        <li class="${params.type == type.english ? 'active' : ''}">
                            <g:link
                                resource="employee/activity"
                                action="weeklyLogistics"
                                params="[employeeId: params.employeeId, type: type.english]">
                                ${type.spanish}
                            </g:link>
                        </li>
                    </g:each>
                </ul>
            </div>
        </sec:ifAnyGranted>

        <div class="btn-group">
            <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                Filtrar por estado <span class="caret"></span>
            </button>

            <ul class="dropdown-menu">
                <g:each in="${toolbar.activityStateList}" var="state">
                    <li class="${params?.state == state ? 'active' : ''}">
                        <g:link
                            resource="employee/activity"
                            action="filter"
                            params="[employeeId: params.employeeId, state: state]">
                            <activity:state currentState="${state}"/>
                        </g:link>
                    </li>
                </g:each>
            </ul>
        </div>

        <g:link
            resource="employee/activity"
            action="create"
            employeeId="${params.employeeId}"
            method="GET"
            class="btn btn-primary">
            Crear actividad
        </g:link>
    </div>
</div>
