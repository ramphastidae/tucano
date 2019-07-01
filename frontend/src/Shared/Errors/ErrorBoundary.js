import React, {Component} from 'react';
import Error5xx from "./Error5xx";

class ErrorBoundary extends Component {

	constructor(props) {
		super(props);
		this.state = {
			error: null,
			errorInfo: null
		};
	}

	componentDidCatch(error, errorInfo) {
		this.setState({
			error: error,
			errorInfo: errorInfo
		});
	}

	render() {
		if (this.state.errorInfo) {
			return (
				<div>
					<Error5xx/>
				</div>
			);
		}

		return this.props.children;
	}
}

export default ErrorBoundary;