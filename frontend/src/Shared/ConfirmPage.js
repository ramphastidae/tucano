import React, { Component } from 'react'
import {Button, Container, Message, Segment} from 'semantic-ui-react'
import {handleError, tupi} from "./Helpers";

class ConfirmPage extends Component {

	constructor(props) {
		super(props);

		this.state = {
			open: false,
			error: {
				visible: false,
				message: ''
			},
			loading: false,
		};

		this.handleError = handleError.bind(this);
		this.handleClose = this.handleClose.bind(this);
		this.handleConfirm = this.handleConfirm.bind(this);
	}

	handleClose(event){
		if(this.props.hasOwnProperty('return')) {
			this.props.history.push(this.props.return);
		}
		else
			this.props.history.goBack();
	}

	handleConfirm(event){
		tupi(
			this.props.method,
			this.props.api,
			this.handleClose,
			this.handleError,
			this.props.hasOwnProperty('data') ? this.props.data : null,
			this.props.headers
		);
	}

	render() {
		return (
			<React.Fragment>
				<Container className='tableContainer'>
					<Segment color='orange'>
						<h3>{this.props.kind}</h3>
						<p>Are you sure you want to {this.props.kind}?</p>
						<Button
							onClick={this.handleClose}
							basic
							color='orange'
							labelPosition='left'
							icon='minus'
							content='No'
						/>
						<Button
							onClick={this.handleConfirm}
							color='orange'
							labelPosition='left'
							icon='checkmark'
							content='Yes'
						/>
						<Message
							negative
							hidden={!this.state.error.visible}
							header='Error'
							content={this.state.error.message}
						/>
					</Segment>
				</Container>
			</React.Fragment>
		)
	}
}

export default ConfirmPage