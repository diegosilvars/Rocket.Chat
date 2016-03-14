atLeastOne = (permissions, scope) ->
	return _.some permissions, (permissionId) ->
		permission = ChatPermissions.findOne permissionId
		return _.some permission.roles, (roleName) ->

			# If anonymous have access, everyone may have access
			if roleName is 'anonymous'
				return true

			role = RocketChat.models.Roles.findOne roleName
			roleScope = role?.scope
			return RocketChat.models[roleScope]?.isUserInRole?(Meteor.userId(), roleName, scope)

all = (permissions, scope) ->
	return _.every permissions, (permissionId) ->
		permission = ChatPermissions.findOne permissionId
		return _.some permission.roles, (roleName) ->

			# If anonymous have access, everyone may have access
			if roleName is 'anonymous'
				return true

			role = RocketChat.models.Roles.findOne roleName
			roleScope = role?.scope
			return RocketChat.models[roleScope]?.isUserInRole?(Meteor.userId(), roleName, scope)

Template.registerHelper 'hasPermission', (permission, scope) ->
	return hasPermission(permission, scope, atLeastOne)

RocketChat.authz.hasAllPermission = (permissions, scope) ->
	return hasPermission(permissions, scope, all)

RocketChat.authz.hasAtLeastOnePermission = (permissions, scope) ->
	return hasPermission(permissions, scope, atLeastOne)

hasPermission = (permissions, scope, strategy) ->
	userId = Meteor.userId()

	unless RocketChat.authz.subscription.ready()
		return false

	permissions = [].concat permissions

	return strategy(permissions, scope)
