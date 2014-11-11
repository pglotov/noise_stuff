app = angular.module 'message.resource', ['ngResource']

.factory 'Message', ['$resource', ($resource)->$resource 'http://cors-anywhere.herokuapp.com/https://api.sendhub.com/v1/messages/', null,
    send:
        method: 'POST'
]
