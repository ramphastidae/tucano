import React from 'react';
import {Button, Container, Form, Grid, Message, Progress, Segment} from 'semantic-ui-react';
import DatePicker from 'react-datepicker';
import TagsInput from 'react-tagsinput';
import './Tags.css';
import {handleChange, handleError, tupi} from '../../Shared/Helpers';
import moment from "moment";

class AddSubjects extends React.Component {

	constructor(props) {
		super(props);

		//TODO: Use Object to generalize Dates
		this.state = {
			id: '',
			name: '',
			vacancies: '',
			subgroup: {
				value: '',
				id: 0,
			},
			subgroupOptions: [],
			conflicts: [],
			numberOfHours: 1,
			subjectDay: [''],
			subjectStart: [new Date()],
			subjectEnd: [new Date()],
			fileReader: new FileReader(),
			errorFile: false,
			errorHour: false,
			content: null,
			totalLoaded: 1,
			current: 1,
			contest: '',
			error: {
				visible: false,
				message: ''
			},
			success: false,
			loading: false
		};

		this.handleChange = handleChange.bind(this);
		this.handleError = handleError.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
		this.handleCreate = this.handleCreate.bind(this);
		this.handleCreateAll = this.handleCreateAll.bind(this);
		this.handleLoad = this.handleLoad.bind(this);
		this.handleOnChangeFile = this.handleOnChangeFile.bind(this);
		this.handleFileRead = this.handleFileRead.bind(this);
		this.handleSubgroupChange = this.handleSubgroupChange.bind(this);
		this.handleDayChange = this.handleDayChange.bind(this);
		this.handleSubgroup = this.handleSubgroup.bind(this);
		this.handleConflicts = this.handleConflicts.bind(this);
	}

	componentWillMount() {
		document.title = 'Tucano - Add New Subject';

		this.setState({
				contest: this.props.match.params.id,
				loading: true,
			}
		);

		tupi(
			'get',
			'/v1/settings',
			this.handleSubgroup,
			this.handleError,
			null,
			{'tenant': this.props.match.params.id}
		);

	}

	handleSubgroup(res){
		if (res && res.hasOwnProperty('data') && res.data.hasOwnProperty('data')) {
			let options = [];

			for(let i=0; i < res.data.data.length; i++){
				options.push({
					key: res.data.data[i].id,
					value: res.data.data[i].attributes.typeKey,
					text: res.data.data[i].attributes.typeKey,
				})
			}

			this.setState({
				subgroupOptions: options,
				loading: false
			});
		}
	}

	changeSubject() {
		if (this.state.current === this.state.totalLoaded) {
			// cleanup
			this.setState({
				id: '',
				name: '',
				vacancies: '',
				subgroup: {value: '', id: 0},
				conflicts: [],
				subjectDay: [''],
				subjectStart: [new Date()],
				subjectEnd: [new Date()],
				numberOfHours: 1,
				totalLoaded: 1,
				current: 1,
				success: true,
				error: {visible: false, message: ''}});
			window.setTimeout(() => {
				this.setState({
					success: false
				});
			}, 5000);
		} else {
			this.setState({current: this.state.current + 1, error: {visible: false, message: ''}});
			this.setBoxesContent(this.state.current);
		}
	}

	createSchedule() {
		let res = [];

		for(let i=0; i < this.state.numberOfHours; i++){
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
		return this.state.id !== '' &&
			this.state.name !== '' &&
			this.state.vacancies !== '' &&
			this.state.subgroup.value !== '';
	}

	async handleCreate(event) {
		let schedule = this.createSchedule();
		let conflicts = this.createConflicts();

		if(this.verifyContent()) {
			await tupi(
				'post',
				'/v1/subjects',
				this.handleSuccess,
				this.handleError,
				{
					'data': {
						attributes: {
							code: this.state.id,
							name: this.state.name,
							openings: parseInt(this.state.vacancies),
							setting_id: this.state.subgroup.id,
							timetables: schedule,
							conflicts: conflicts
						},
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

	async handleSuccess(res) {
		await this.changeSubject();
	}

	async handleCreateAll(event) {
		this.setState({loading: true});
		for (let i = this.state.current; i <= this.state.totalLoaded; i++) {
			await this.handleCreate();
			if(this.state.error.visible || this.state.errorHour || this.state.errorFile){
				break;
			}
		}
		this.setState({loading: false});
	}

	handleLoad() {
		//Opens de Upload Window
		this.refs.fileUploader.click();
	}

	static isValidTime(d) {
		return !isNaN(d[0]) && !isNaN(d[1]);
	}

	validateSubgroup(subgroup){
		let valid = false;

		for(let i=0; i < this.state.subgroupOptions.length; i++){
			if(this.state.subgroupOptions[i].value === subgroup) {

				let result = {value: subgroup, id: this.state.subgroupOptions[i].key};
				this.setState({subgroup: result });
				valid = true;
			}
		}

		if(!valid){
			this.setState({errorFile:true, subgroup: {value:'', id: 0}});
		}

	}

	setBoxesContent(current) {
		current--;
		let jsonObject = this.state.content;

		this.setState({
			id: jsonObject.subjects[current].id,
			name: jsonObject.subjects[current].name,
			vacancies: jsonObject.subjects[current].vacancies,
			conflicts: (jsonObject.subjects[current].hasOwnProperty("conflicts")) ? jsonObject.subjects[current].conflicts.split(',') : [],
			subjectStart: [new Date()],
			subjectEnd: [new Date()],
			errorHour: false,
			numberOfHours: jsonObject.subjects[current].schedule.length
		});

		//Set valid subgroup
		this.validateSubgroup(jsonObject.subjects[current].subgroup);

		//Set dates boxes
		try{
			for (let i = 0; i < jsonObject.subjects[current].schedule.length; i++) {
				let day = jsonObject.subjects[current].schedule[i].day;

				if (day > 0 && day < 8) {

					let dayAux = this.state.subjectDay;
					dayAux[i] = day;

					this.setState({
						subjectDay: dayAux,
						errorHour: false,
					});

				} else {
					this.setState({errorHour: true});
				}

				let start = jsonObject.subjects[current].schedule[i].hourStart.split(":");
				let end = jsonObject.subjects[current].schedule[i].hourEnd.split(":");

				if (AddSubjects.isValidTime(start) && AddSubjects.isValidTime(end)) {
					let stAux = this.state.subjectStart;
					let endAux = this.state.subjectEnd;

					stAux.push(new Date());
					endAux.push(new Date());

					stAux[i].setHours(start[0]);
					stAux[i].setMinutes(start[1]);

					endAux[i].setHours(end[0]);
					endAux[i].setMinutes(end[1]);

					this.setState({
						subjectStart: stAux,
						subjectEnd: endAux,
						errorHour: false,
						numberOfHours: jsonObject.subjects[current].schedule.length,
					});
				} else {
					this.setState({errorHour: true});
				}
			}
		} catch(e) {
			this.setState({errorHour: true});
		}
	}

	handleFileRead() {
		try {
			const content = this.state.fileReader.result;
			const jsonObject = JSON.parse(content);

			this.setState({
				totalLoaded: jsonObject.subjects.length,
				errorFile: false,
				content: jsonObject,
				current: 1
			});

			this.setBoxesContent(1);
		} catch (e) {
			this.setState({errorFile: true});
		}
	}

	handleOnChangeFile(event) {
		event.stopPropagation();
		event.preventDefault();

		if (event.target.files[0]) {
			let fr = this.state.fileReader;
			fr.onloadend = this.handleFileRead;
			this.setState({fileReader: fr});
			this.state.fileReader.readAsText(event.target.files[0]);
		}

		event.target.value = null;
	}

	handleSubgroupChange(event, e) {
		let option = this.state.subgroupOptions.find(o => o.value === e.value);
		let res = {value: e.value, id: parseInt(option.key)};
		this.setState({subgroup: res});
	}

	handleDayChange(event, e) {
		let aux = this.state.subjectDay;
		aux[e.id] = e.value;

		this.setState({day: aux});
	}

	handleChangeStart(selected, i) {
		let aux = this.state.subjectStart;
		aux[i] = selected;
		this.setState({subjectStart: aux});
	}

	handleChangeEnd(selected, i) {
		let aux = this.state.subjectEnd;
		aux[i] = selected;
		this.setState({subjectEnd: aux});
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

	handleConflicts(tags) {
		this.setState({conflicts: tags})
	}

	renderForm = () => {
		const weekDays = [
			{key: 1, text: 'Monday', value: 1},
			{key: 2, text: 'Tuesday', value: 2},
			{key: 3, text: 'Wednesday', value: 3},
			{key: 4, text: 'Thursday', value: 4},
			{key: 5, text: 'Friday', value: 5},
			{key: 6, text: 'Saturday', value: 6},
			{key: 7, text: 'Sunday', value: 7},
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
							<label>Start time</label><br/>
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
							<label>End time</label><br/>
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
					<Segment color='orange' loading={this.state.loading}>
						<Grid columns='equal' stackable>
							<Grid.Column>
								<h3>New Subject Info</h3>
							</Grid.Column>
							<Grid.Column textAlign='right'>
								<input
									type="file"
									id="file"
									ref="fileUploader"
									style={{display: "none"}}
									onChange={this.handleOnChangeFile}
								/>
								<Button
									icon='upload'
									color='orange'
									labelPosition='left'
									size='small'
									onClick={this.handleLoad}
									content='Upload JSON'
								/>
							</Grid.Column>
						</Grid>
						<p/>
						<Message
							hidden={!this.state.errorFile}
							negative
							header='Uploading Subjects info failed'
							content="File is badly constructed"
						/>
						<Form>
							<Form.Input
								required={true}
								label='Id Code'
								name='id'
								value={this.state.id}
								onChange={this.handleChange}
							/>
							<Form.Dropdown
								required={true}
								label='Subgroup'
								name='subgroup'
								fluid
								selection
								value={this.state.subgroup.value}
								onChange={this.handleSubgroupChange}
								options={this.state.subgroupOptions}
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
							<Message
								hidden={!this.state.errorHour}
								negative
								header='Uploading Contest info failed'
								content="Hours are badly constructed"
							/>
							<Segment color='black'>
								<Grid columns='equal' stackable>
									<Grid.Column>
										<h4>Set Subject Schedules</h4>
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
							hidden={!this.state.success}
							success
							header='Subject Added'
							content="The new subject was created with success"
						/>
						<Message
							hidden={!this.state.error.visible}
							negative
							header='Creation of Subject failed'
							content={this.state.error.message}
						/>
						<Grid columns='equal' stackable>
							<Grid.Column>
								<Button
									icon='add'
									labelPosition='left'
									color='orange'
									size='large'
									onClick={this.handleCreate}
									content='Add Subject'
								/>
							</Grid.Column>
							<Grid.Column>
								<Progress
									value={this.state.current}
									total={this.state.totalLoaded}
									size='medium'
									label={'Progress: ' + this.state.current + '/' + this.state.totalLoaded}
								/>
							</Grid.Column>
							<Grid.Column textAlign='right'>
								<Button
									disabled={this.state.totalLoaded === 1}
									icon='forward'
									labelPosition='right'
									color='orange'
									size='large'
									onClick={this.handleCreateAll}
									content='Add All'
								/>
							</Grid.Column>
						</Grid>
					</Segment>
				</Container>
			</div>
		);
	}
}

export default AddSubjects;
