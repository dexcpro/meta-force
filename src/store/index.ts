import { createStore } from 'vuex'

export default createStore({
	state: {
		id: null,
		address:null,
		admin:null,
		start:'未知',
		fullscreenLoading:true

	},
	mutations: {
		setId(state, value) {
			state.id = value
		},
		setAddress(state, value) {
			state.address = value
		},
		setAdmin(state, value) {
			state.admin = value
		},
		setStart(state, value) {
			state.start = value
		},
		setFullscreenLoading(state, value) {
			state.fullscreenLoading = value
		},
	},
	getters: {},
	actions: {},
	modules: {},
})