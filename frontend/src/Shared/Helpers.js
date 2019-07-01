import axios from 'axios';

export function handleError(error) {
	this.setState({loading: false});

	if (error.response &&
		error.response.data.hasOwnProperty('error') &&
		(error.response.data.error === 'unauthenticated' ||
			error.response.data.error === 'invalid_token') &&
		error.response.statusText !== 'Unauthorized'
	) {
		localStorage.removeItem('token');
		localStorage.removeItem('usertype');
		localStorage.removeItem('userid');
		this.props.history.push('/login');
	} else {
		if (error.response == null) {
			this.setState({
				error: {
					visible: true,
					message: 'Network Error. Please try again later.'
				}
			});
		} else if (error.response.status === 401) {
			this.setState({
				error: {
					visible: true,
					message: 'This content is not available'
				}
			});
		} else if (error.response.status === 404) {
			this.setState({
				error: {
					visible: true,
					message: 'This content does not exist'
				}
			});
		}
		else if (error.response.status === 422 || error.response.status === 400 || error.response.status >= 500) {
			this.setState({
				error: {
					visible: true,
					message: 'Something went wrong'
				}
			});
		}
		else {
			this.setState({
				error: {
					visible: true,
					message: 'Error ' + error.response.status + ' - ' + error.response.statusText
				}
			});
		}
	}
}

export function handleChange(e) {
	let el = (e.target ? e.target : e);
	this.setState({[el.name]: el.value});
}

export function tupi(method, endpoint, onfulfilled, onrejected, data, headers) {
	const api_endpoint = process.env.REACT_APP_API + endpoint;

	headers = headers || {};
	headers['Authorization'] = 'Bearer ' + localStorage.getItem('token');
	headers['content-type'] = 'application/vnd.api+json';
	headers['accept'] = 'application/vnd.api+json';

	let config = {};
	config['method'] = method;
	config['url'] = api_endpoint;
	config['headers'] = headers;
	if (data) config['data'] = data;

	return axios(config)
		.then(onfulfilled)
		.catch(onrejected);
}
