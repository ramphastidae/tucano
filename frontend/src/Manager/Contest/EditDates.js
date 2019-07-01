import React from 'react';
import {Button, Container, Message, Segment} from 'semantic-ui-react';
import moment from 'moment';
import DateRangePicker from "react-daterange-picker";
import {handleError, tupi} from "../../Shared/Helpers";

class EditDates extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			dateRange: null,
			loading: true,
			error: {
				visible: false,
				message: ''
			}
		};

		this.handleError = handleError.bind(this);
		this.handleContest = this.handleContest.bind(this);
		this.handleSelect = this.handleSelect.bind(this);
		this.handleEditDates = this.handleEditDates.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
	}

	componentDidMount() {
		document.title = 'Tucano - Edit Contest Period';

		tupi(
			'get',
			'/v1/contests/' + this.props.match.params.id,
			this.handleContest,
			this.handleError
		);
	}

	handleContest(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
			const attributes = res.data.data.attributes;

			this.setState({
				loading: false,
				dateRange: moment.range(
					moment(attributes.begin, 'YYYY-MM-DD'),
					moment(attributes.end, 'YYYY-MM-DD')
				)
			});
		}
	}

	handleSelect(range, states) {
		this.setState({
			dateRange: range,
			states: states
		});
	}

	handleEditDates() {
		tupi(
			'patch',
			'/v1/contests/' + this.props.match.params.id,
			this.handleSuccess,
			this.handleError,
			{
				'data': {
					attributes: {
						begin: this.state.dateRange.start.format('YYYY-MM-DDTHH:mm:ss'),
						end: this.state.dateRange.end.add(86399, 'seconds').format('YYYY-MM-DDTHH:mm:ss')
					},
					id: this.props.match.params.id,
					type: 'contests'
				}
			},
			{'tenant': this.props.match.params.id,}
		);
	}

	handleSuccess() {
		this.props.history.push('/manager/contests/' + this.props.match.params.id);
	}

	render() {
		return (
			<React.Fragment>
				<Container className='tableContainer'>
					<Segment color='orange' loading={this.state.loading}>
						<h3>Edit Contest Period</h3>
						<Segment basic>
						<DateRangePicker
							firstOfWeek={1}
							numberOfCalendars={2}
							selectionType='range'
							value={this.state.dateRange}
							onSelect={this.handleSelect}
						/>
						<Message
							hidden={!this.state.error.visible}
							negative
							header='Update Failed'
							content={this.state.error.message}
						/>
						</Segment>
						<Button
							icon='edit'
							labelPosition='left'
							color='orange'
							size='large'
							onClick={this.handleEditDates}
							content='Confirm Changes'
						/>
					</Segment>
				</Container>
			</React.Fragment>
		);
	}
}

export default EditDates;
