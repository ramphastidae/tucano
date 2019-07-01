import React from 'react';
import {Button, Container, Form, Grid, Message, Segment} from 'semantic-ui-react';
import DatePicker from 'react-datepicker';
import {handleChange, handleError, tupi} from '../../Shared/Helpers';
import TagsInput from "react-tagsinput";
import './Tags.css';
import moment from "moment";

class EditSubjects extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			id: '',
			name: '',
			vacancies: '',
			subgroup: '',
			conflicts: [],
			numberOfHours: 1,
			subjectDay: [''],
			subjectStart: [new Date()],
			subjectEnd: [new Date()],
			error: {
				visible: false,
				message: ''
			},
			contest: ''
		};

		this.handleError = handleError.bind(this);
		this.handleChange = handleChange.bind(this);
		this.handleConflicts = this.handleConflicts.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
		this.handleSubject = this.handleSubject.bind(this);
		this.handleCreate = this.handleCreate.bind(this);
		this.handleSubgroupChange = this.handleSubgroupChange.bind(this);
		this.handleChangeEnd = this.handleChangeEnd.bind(this);
		this.handleChangeStart = this.handleChangeStart.bind(this);
	}

	componentWillMount() {
		document.title = 'Tucano - Edit Subject';

		this.setState({
				contest: this.props.match.params.id,
				loading: true,
			}
		);

		tupi(
			'get',
			'/v1/subjects/' + this.props.match.params.subject,
			this.handleSubject,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);
	}

	handleSubject(res) {
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
			this.setState({
				name: res.data.data.attributes.name || 'No name specified',
				id: res.data.data.attributes.code || 'No code specified',
				vacancies: res.data.data.attributes.openings || 'No vacancies specified',
			});

			this.parseData(res.data.included);
			this.setState({loading: false});
		}
	}

	parseData(data) {

		let auxDates = [];
		let auxConflicts = [];

		for(let i=0; i<data.length; i++){
			if(data[i].type === "settings") {
				this.setState({subgroup: data[i].attributes.typeKey});
			}
			if(data[i].type === "timetables") {
				auxDates.push(data[i].attributes);
			}
			if(data[i].type === "conflicts") {
				auxConflicts.push(data[i].attributes.subjectCode);
			}
		}
		this.setState({conflicts: auxConflicts});
		this.parseSchedule(auxDates);
	}

	parseSchedule(data) {
		this.setState({numberOfHours: data.length});
		let stAux = [], endAux = [], dayAux = [];

		for (let i = 0; i < data.length; i++) {
			let start = data[i].begin.split(":");
			let end = data[i].end.split(":");

			stAux.push(new Date());
			endAux.push(new Date());
			dayAux.push(data[i].weekday);

			stAux[i].setHours(start[0]);
			stAux[i].setMinutes(start[1]);

			endAux[i].setHours(end[0]);
			endAux[i].setMinutes(end[1]);
		}
		this.setState({
			subjectDay: dayAux,
			subjectStart: stAux,
			subjectEnd: endAux
		});
	}

	createSchedule() {
		let res = [];

		for(let i=0; i < this.state.subjectDay.length; i++){
			res.push({
				begin: moment(this.state.subjectStart[i].setSeconds(0,0)).format('HH:mm:ss'),
				end: moment(this.state.subjectEnd[i].setSeconds(0,0)).format('HH:mm:ss'),
				weekday: this.state.subjectDay[i]
			});
		}

		return res;
	}

	createConflicts() {
		let res = [];

		for(let i=0; i < this.state.conflicts.length; i++){
			res.push({
				subject_code: this.state.conflicts[i]
			});
		}

		return res;
	}

	verifyContent() {
		for(let i=0; i<this.state.numberOfHours; i++){
			if(this.state.subjectDay[i] === '') return false;
		}
		return this.state.name !== '' &&
			this.state.vacancies !== '';
	}

	handleCreate(event) {
		let schedule = this.createSchedule();
		let conflicts = this.createConflicts();

		if(this.verifyContent()) {
			tupi(
				'patch',
				'/v1/subjects/' + this.props.match.params.subject,
				this.handleSuccess,
				this.handleError,
				{
					'data': {
						attributes: {
							name: this.state.name,
							openings: parseInt(this.state.vacancies),
							timetables: schedule,
							conflicts: conflicts
						},
						id: this.props.match.params.subject,
						type: 'subjects'
					}
				},
				{'tenant': this.state.contest}
			);
		}
		else {
			let error = {visible: true, message: 'Please fill all required fields'};
			this.setState({error: error});
		}
	}

	handleSuccess() {
		this.props.history.push('/manager/contests/' + this.props.match.params.id + '/subjects');
	}

	handleSubgroupChange(event) {
		let el = event.target;
		this.setState({subgroup: el.value})
	}

	handleChangeStart(selected) {
		this.setState({startDate: selected});
	}

	handleChangeEnd(selected) {

		this.setState({endDate: selected});
	}

	handleDayChange(event, e) {
		let aux = this.state.subjectDay;
		aux[e.id] = e.value;
		this.setState({day: aux});
	}

	handleConflicts(tags) {
		this.setState({conflicts: tags})
	}

	handleSubsetClick(value) {
		if (this.state.numberOfHours + value > 0) {
			this.setState({numberOfHours: this.state.numberOfHours + value});

			if (value > 0) {
				this.state.subjectStart.push(new Date());
				this.state.subjectEnd.push(new Date());
			} else if (value < 0) {
				this.state.subjectStart.pop();
				this.state.subjectEnd.pop();
			}
		}
	}

	renderForm = () => {
		const weekDays = [
			{key: 1, text: 'Monday', value: 1},
			{key: 2, text: 'Tuesday', value: 2},
			{key: 3, text: 'Wednesday', value: 3},
			{key: 4, text: 'Thursday', value: 4},
			{key: 5, text: 'Friday', value: 5},
		];

		return (
			[...Array(this.state.numberOfHours)]
				.map((e, i) =>
					<Grid columns='equal' key={i} stackable>
						<Grid.Column>
							<Form.Dropdown
								required={true}
								name='day'
								id={i}
								label='Week day'
								value={this.state.subjectDay[i]}
								onChange={this.handleDayChange}
								options={weekDays}
								selection
							/>
						</Grid.Column>
						<Grid.Column>
							<label>Start time:</label><br/>
							<DatePicker
								dropdownMode='select'
								selected={this.state.subjectStart[i]}
								showTimeSelect
								showTimeSelectOnly
								dateFormat='HH:mm'
								timeFormat='HH:mm'
								timeIntervals={30}
								timeCaption='time'
								onChange={(e) => this.handleChangeStart(e, i)}

							/>
						</Grid.Column>
						<Grid.Column>
							<label>End time:</label><br/>
							<DatePicker
								dropdownMode='select'
								selected={this.state.subjectEnd[i]}
								showTimeSelect
								showTimeSelectOnly
								dateFormat='HH:mm'
								timeFormat='HH:mm'
								timeIntervals={30}
								timeCaption='time'
								onChange={(e) => this.handleChangeEnd(e, i)}
							/>
						</Grid.Column>
					</Grid>
				)
		);
	};

	render() {
		return (
			<div>
				<Container className='tableContainer'>
					<Segment color='orange'>
						<Grid columns='equal' stackable>
							<Grid.Column>
								<h3>Edit Subject Info</h3>
							</Grid.Column>
						</Grid>
						<p/>
							<Form.Group>
								<Form>
									<Form.Input
										disabled
										label='Id Code'
										name='id'
										value={this.state.id}
									/>
									<Form.Input
										disabled
										label='Subgroup'
										fluid
										value={this.state.subgroup}
									/>
									<Form.Input
										required={true}
										label='Name'
										name='name'
										value={this.state.name}
										onChange={this.handleChange}
									/>
									<Form.Input
										required={true}
										label='Vacancies'
										name='vacancies'
										type='number'
										value={this.state.vacancies}
										onChange={this.handleChange}
									/>
									<Segment color='black'>
										<Grid columns='equal' stackable>
											<Grid.Column>
												<h4>Edit Subject Schedules</h4>
											</Grid.Column>
											<Grid.Column textAlign='right'>
												<Button.Group>
													<Button
														icon='plus'
														color='orange'
														size='small'
														onClick={() => this.handleSubsetClick(1)}
													/>
													<Button
														icon='minus'
														color='orange'
														size='small'
														onClick={() => this.handleSubsetClick(-1)}
													/>
												</Button.Group>
											</Grid.Column>
										</Grid>
										{this.renderForm()}
									</Segment>
								</Form>
								<p/>
								<label>Conflicts</label><br/>
								<TagsInput
									inputProps={{placeholder: 'Subject code'}}
									onlyUnique={true}
									value={this.state.conflicts}
									onChange={this.handleConflicts}
								/>
								<p/>
								<Message
									hidden={!this.state.error.visible}
									negative
									header='Update of Subject failed'
									content={this.state.error.message}
								/>
								<Button
									icon='edit'
									labelPosition='left'
									color='orange'
									size='large'
									onClick={this.handleCreate}
									content='Confirm Changes'
								/>
							</Form.Group>
						</Segment>
				</Container>
			</div>
		);
	}
}

export default EditSubjects;
