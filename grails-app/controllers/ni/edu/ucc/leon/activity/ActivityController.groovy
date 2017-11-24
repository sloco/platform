package ni.edu.ucc.leon.activity

import com.craigburke.document.builder.PdfDocumentBuilder
import ni.edu.ucc.leon.EmployeeCoordinationService
import grails.validation.ValidationException
import ni.edu.ucc.leon.EmployeeCoordination
import ni.edu.ucc.leon.ActivityService
import ni.edu.ucc.leon.EmployeeService
import ni.edu.ucc.leon.LocationService
import ni.edu.ucc.leon.TableLinen
import ni.edu.ucc.leon.Activity
import ni.edu.ucc.leon.Employee
import ni.edu.ucc.leon.Location
import ni.edu.ucc.leon.Helper

class ActivityController {

    EmployeeCoordinationService employeeCoordinationService
    EmployeeService employeeService
    ActivityService activityService
    LocationService locationService

    static allowedMethods = [ save: 'POST', update: 'PUT', delete: 'DELETE', sendNotification: 'PUT' ]

    def index(final Long employeeId) {
        respond ([activityList: activityService.listByEmployeeAndState(employeeId, 'created')], model: [toolbar: createToolbar(employeeId)])
    }

    def create(final Long employeeId) {
        [
            nameList: activityService.activityNamesPerEmployee(employeeId),
            employeeCoordinations: employeeCoordinationService.listByEmployee(employeeService.find(employeeId))
        ]
    }

    def save(final Long employeeId, final String name, final Long organizedBy) {
        try {
            Activity activity = activityService.save(employeeId, name, organizedBy)

            flash.message = 'Actividad creada'
            redirect uri: "/employees/${employeeId}/activities/${activity.id}", method: 'GET'
        } catch(ValidationException e) {
            render view: 'create', model: [
                errors: e.errors,
                nameList: activityService.activityNamesPerEmployee(employeeId),
                employeeCoordinations: employeeCoordinationService.listByEmployee(employeeService.find(employeeId))
            ]
        }
    }

    def show(final Long id, final Long employeeId) {
        Activity activity = activityService.find(id)

        [activity: activity]
    }

    def edit(final Long id, final Long employeeId) {
        Employee employee = employeeService.find(employeeId)

        [
            activity: activityService.find(id),
            nameList: activityService.activityNamesPerEmployee(employeeId),
            employeeCoordinations: employeeCoordinationService.listByEmployee(employee)
        ]
    }

    def update(final Long id, final Long employeeId, final String name, final Long organizedBy) {
        try {
            Activity activity = activityService.update(id, name, organizedBy)

            if (!activity) {
                notFound(employeeId)

                return
            }

            flash.message = 'Actividad actualizada'
            redirect uri: "/employees/${employeeId}/activities/${activity.id}", method: 'GET'
        } catch(ValidationException e) {
            render view: 'edit', model: [
                errors: e.errors,
                activity: activityService.find(id),
                nameList: activityService.activityNamesPerEmployee(employeeId),
                employeeCoordinations: employeeCoordinationService.listByEmployee(employeeService.find(employeeId))
            ]
        }
    }

    def delete(final Long id, final Long employeeId) {
        Activity activity = activityService.delete(id)

        if (!activity) {
            notFound(employeeId)

            return
        }

        flash.message = 'Actividad eliminada'
        redirect uri: "/employees/$employeeId/activities", method: 'GET'
    }

    def sendNotification(final Long employeeId, final Long activityId, final String state) {
        Activity activity = activityService.find(activityId)

        if (!activity || !activity.locations) {
            flash.message = 'Ubicaciones son necesarias para continuar'

            redirect uri: "/employees/$employeeId/activities/$activityId", method: 'GET'
            return
        }

        activityService.updateState(state ?: getNextNotificationState(), activityId)

        flash.message = 'Estado actualizado'
        redirect uri: "/employees/$employeeId/activities/$activityId", method: 'GET'
    }

    def filter(final Long employeeId, final String state) {
        respond ([activityList: activityService.listByEmployeeAndState(employeeId, state)], model: [toolbar: createToolbar(employeeId)], view: 'index')
    }

    def requiringAttention(final Long employeeId) {
        final List<Map> results = listRequiringAttention(employeeId)
        final List<Map> activityListByOrganizer = results.groupBy { it.organizer }.collect {
            [organizer: it.key, activities: it.value.collect {
                [id: it.id, name: it.name]
            }]
        }

        respond ([activityListByOrganizer: activityListByOrganizer], model: [toolbar: createToolbar(employeeId)])
    }

    def weeklyLogistics(final Long employeeId, final String type) {
        respond ([results: locationService.listWeeklyLogistics(type)], model: [toolbar: createToolbar(employeeId)])
    }

    def printWeeklyLogistics(final Long employeeId, final String type) {
        PdfDocumentBuilder pdfBuilder = new PdfDocumentBuilder(response.outputStream)
        List<Map> logisticList = locationService.listWeeklyLogistics(type)
        Closure template = {
            'document' font: [family: 'Courier', size: 7.pt], margin: [top: 0.3.inches, left: 0.3.inches, right: 0.3.inches]
        }

        pdfBuilder.create {
            document (
                template: template,

                header: { info ->
                    table(border: [size: 0]) {
                        row {
                            cell "UCC LEON - Protocolo - Logistica semanal del ${Helper.FIRST_DAY_OF_WEEK().format('yyyy-MM-dd')} al ${Helper.LAST_DAY_OF_WEEK().format('yyyy-MM-dd')}", align: 'center'
                        }
                    }
                },

                footer: { info ->
                    table(border: [size: 0]) {
                        row {
                            cell 'Elaborado por: Orlando Gaitan Coordinador de protocolo', align: 'center'
                        }
                    }
                }
            ) {
                table(padding: 3.px) {
                    row {
                        cell 'Lugar'
                        cell 'Nombre'
                        cell 'Horario'
                        cell 'Participantes'

                        if (type == 'concierge') {
                            cell 'Montaje'
                        }

                        if (type == 'protocol') {
                            cell 'Manteleria'
                            cell 'B. de agua'
                            cell 'Refrigerios'
                        }

                        cell 'Requerimiento'
                    }

                    logisticList.each { logistic ->
                        row {
                            cell logistic.date, colspan: logistic.locations[0].size() - 1
                        }

                        logistic.locations.each { location ->
                            row {
                                cell location.place
                                cell location.name
                                cell "$location.startTime a $location.endTime"
                                cell location.participants

                                if (type == 'concierge') {
                                    cell location.typeOfAssembly
                                }

                                if (type == 'protocol') {
                                    cell join(in: location.tableLinen)
                                    cell location.waterBottles
                                    cell location?.refreshment?.quantity
                                }

                                cell join(in: location.requirements)
                            }
                        }
                    }
                }
            }
        }

        response.contentType = "application/pdf"
        response.setHeader("Content-disposition", "attachment;filename=test.pdf")
        response.outputStream.flush()
    }

    protected void notFound(final Long employeeId) {
        flash.message = 'Actividad no encontrada'

        redirect uri: "/employees/$employeeId/activities", method: 'GET'
    }

    private final String getNotificationState() {
        List<String> authorityList = authenticatedUser.authorities.authority

        if ('ROLE_COORDINATOR' in authorityList) return 'notified'

        if ('ROLE_ACADEMIC_COORDINATOR' in authorityList) return 'confirmed'

        if ('ROLE_ADMINISTRATIVE_COORDINATOR' in authorityList) return 'approved'

        if ('ROLE_PROTOCOL' in authorityList) return 'authorized'
    }

    private final String getNextNotificationState() {
        List<String> authorityList = authenticatedUser.authorities.authority

        if ('ROLE_ASSISTANT' in authorityList) return 'notified'

        if ('ROLE_COORDINATOR' in authorityList) return 'confirmed'

        if ('ROLE_ACADEMIC_COORDINATOR' in authorityList) return 'approved'

        if ('ROLE_ADMINISTRATIVE_COORDINATOR' in authorityList) return 'authorized'

        if ('ROLE_PROTOCOL' in authorityList) return 'attended'
    }

    private final Boolean isSupervisor() {
        final List<String> supervisorList = ['ROLE_ACADEMIC_COORDINATOR', 'ROLE_ADMINISTRATIVE_COORDINATOR', 'ROLE_PROTOCOL']
        final List<String> authorityList = authenticatedUser.authorities.authority

        supervisorList.any { authority -> authority in authorityList }
    }

    private final List<Map> listRequiringAttention(final Long employeeId) {
        final String state = getNotificationState()

        if (isSupervisor()) return activityService.listRequiringAttention(state)

        activityService.listRequiringAttention(state, employeeId)
    }

    private final Number countRequiringAttention(final Long employeeId) {
        final String state = getNotificationState()

        if (isSupervisor()) return activityService.countRequiringAttention(state)

        activityService.countRequiringAttention(state, employeeId)
    }

    private Toolbar createToolbar(final Long employeeId) {
        new Toolbar (
            notificationNumber: countRequiringAttention(employeeId),
            logisticsTypeList: Helper.LOGISTICS_TYPE_LIST,
            activityStateList: Helper.ACTIVITY_STATE_LIST
        )
    }
}

class Toolbar {
    Integer notificationNumber
    List<LinkedHashMap> logisticsTypeList
    List<LinkedHashMap> activityStateList
}
