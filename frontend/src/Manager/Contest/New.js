import React from 'react';
import {Button, Container, Form, Grid, Message, Segment} from 'semantic-ui-react';
import moment from 'moment';
import DateRangePicker from 'react-daterange-picker';
import {handleError, handleChange, tupi} from '../../Shared/Helpers';

class NewContest extends React.Component {
	constructor(props) {
		super(props);

		this.state = {
			id: '',
			numberOfSubgroups: 1,
			subName: [''],
			numAlloc: [''],
			dateRange: null,
			fileReader: new FileReader(),
			errorDate: false,
			errorFile: false,
			success: false,
			loading: false,
			error: {
				visible: false,
				message: ''
			}
		};

		this.handleChange = handleChange.bind(this);
		this.handleError = handleError.bind(this);
		this.handleSuccess = this.handleSuccess.bind(this);
		this.handleCreate = this.handleCreate.bind(this);
		this.handleLoad = this.handleLoad.bind(this);
		this.handleOnChangeFile = this.handleOnChangeFile.bind(this);
		this.handleSubGroupChange = this.handleSubGroupChange.bind(this);
		this.handleSelect = this.handleSelect.bind(this);
		this.handleFileRead = this.handleFileRead.bind(this);
	}

	componentDidMount() {
		document.title = 'Tucano - Add Contest';
	}

	handleCreate(event) {
		if(this.verifyInputContent()) {
			this.setState({loading: true});

			tupi(
				'post',
				'/v1/contests',
				this.handleSuccess,
				this.handleError,
				{
					'data': {
						attributes: {
							begin: this.state.dateRange.start.format('YYYY-MM-DDTHH:mm:ss'),
							end: this.state.dateRange.end.add(86399, 'seconds').format('YYYY-MM-DDTHH:mm:ss'),
							name: this.state.id,
							settings: this.generateSettings()
						},
						type: 'contests'
					}
				}
			);
		}
		else {
			let error = {visible: true, message: 'Please fill all required fields'};
			this.setState({error: error});
		}
	}

	verifyInputContent() {
		if(this.state.dateRange === null) {
			this.setState({errorDate: true});
			return false;
		}

		this.setState({errorDate: false});

		for(let i=0; i<this.state.numberOfSubgroups; i++) {
			if(this.state.subName[i] === '' ) return false;
			if(this.state.numAlloc[i] === '') return false;
		}

		return this.state.id !== '';
	}

	handleSuccess(res) {
		this.setState({
			id: '',
			numberOfSubgroups: 1,
			subName: [''],
			numAlloc: [''],
			dateRange: null,
			fileReader: new FileReader(),
			errorDate: false,
			errorFile: false,
			error: {
				visible: false,
				message: ''
			},
			success: true,
			loading: false,
		});
		window.setTimeout(() => {
			this.setState({
				success: false
			});
		}, 5000);
	}

	handleLoad() {
		//opens de upload window
		this.refs.fileUploader.click();
	}

	static isValidDate(d) {
		return d instanceof Date && !isNaN(d);
	}

	handleFileRead() {
		try {
			const content = this.state.fileReader.result;
			const jsonObject = JSON.parse(content);

			//Set content subgroups boxes
			for (let i = 0; i < jsonObject.subgroups.length; i++) {
				const numAllocAux = this.state.numAlloc;
				const subNameAux = this.state.subName;

				numAllocAux[i] = jsonObject.subgroups[i].allocations;
				subNameAux[i] = jsonObject.subgroups[i].name;

				this.setState({numAlloc: numAllocAux, subName: subNameAux});
			}

			this.setState({
				id: jsonObject.name,
				numberOfSubgroups: jsonObject.subgroups.length,
				errorFile: false,
			});

			//Set dates boxes
			let start = new Date(jsonObject.startDate);
			let end = new Date(jsonObject.endDate);

			if (NewContest.isValidDate(start) && NewContest.isValidDate(end)) {
				const start = moment(jsonObject.startDate, 'YYYY-MM-DD');
				const end = moment(jsonObject.endDate, 'YYYY-MM-DD');
				const range = moment.range(start, end);

				this.setState({
					dateRange: range,
					errorDate: false
				});
			} else {
				this.setState({errorDate: true});
			}
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

	handleSubsetClick(value) {
		if (this.state.numberOfSubgroups + value > 0) {
			this.setState({numberOfSubgroups: this.state.numberOfSubgroups + value});

			if (value > 0) {
				this.state.subName.push('');
				this.state.numAlloc.push('');
			} else if (value < 0) {
				this.state.subName.pop();
				this.state.numAlloc.pop();
			}
		}
	}

	handleSubGroupChange(event) {
		let el = event.target;
		const a = this.state[el.name];
		a[el.id] = el.value;
		this.setState({[el.name]: a});
	}

	handleSelect(range, states) {
		this.setState({
			dateRange: range,
			states: states
		});
	}

	generateSettings() {
		let result = [];

		for (let i = 0; i < this.state.numberOfSubgroups; i++) {
			result.push({allocations: this.state.numAlloc[i], type_key: this.state.subName[i]});
		}

		return result;
	}

	renderForm() {
		return (
			[...Array(this.state.numberOfSubgroups)]
				.map((e, i) =>
					<Form key={i}>
						<p><u>Subgroup {i + 1}</u></p>
						<Form.Group widths='equal'>
							<Form.Input
								required={true}
								label='Name'
								name='subName'
								id={i}
								value={this.state.subName[i]}
								onChange={this.handleSubGroupChange}
							/>
							<Form.Input
								required={true}
								type='number'
								label='Number of Allocations'
								name='numAlloc'
								id={i}
								value={this.state.numAlloc[i]}
								onChange={this.handleSubGroupChange}
							/>
						</Form.Group>
					</Form>)
		);
	}

	render() {
		const DatePickerForm = () => (
			<Segment color='black'>
				<h4>Set Date Range</h4>
				<DateRangePicker
					firstOfWeek={1}
					numberOfCalendars={2}
					selectionType='range'
					value={this.state.dateRange}
					onSelect={this.handleSelect}
				/>
				<Message
					hidden={!this.state.errorDate}
					negative
					header='Date Error'
					content='Dates are invalid'
				/>
			</Segment>
		);

		return (
			<div>
				<Container className='tableContainer'>
					<Segment color='orange' loading={this.state.loading}>
						<Grid columns='equal' stackable>
							<Grid.Column>
								<h3>Input New Contest Info</h3>
							</Grid.Column>
							<Grid.Column textAlign='right'>
								<input
									type='file'
									id='file'
									ref='fileUploader'
									style={{display: 'none'}}
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
						<Message
							hidden={!this.state.errorFile}
							negative
							header='Uploading Contest info failed'
							content='File is badly constructed'
						/>
						<Form.Group size='large'>
							<Form>
								<Form.Input
									required={true}
									label='Name of Contest'
									name='id'
									type='text'
									value={this.state.id}
									onChange={this.handleChange}
								/>
								<p>
									<b>Your URL preview: </b>
									{window.location.host +
									'/manager/contests/'
									+ (this.state.id.toLowerCase()
										.replace(/[^a-zA-Z0-9-_]/g, '-') || '<name>')}
								</p>
							</Form>
							<Segment color='black'>
								<Grid columns='equal' stackable>
									<Grid.Column>
										<h4>Set Configurations of Subgroup</h4>
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
							<DatePickerForm/>
							<Message
								hidden={!this.state.success}
								success
								header='Contest Added'
								content='The new contest was created with success'
							/>
							<Message
								hidden={!this.state.error.visible}
								negative
								header='Creation of Contest Failed'
								content={this.state.error.message}
							/>
							<Button
								icon='add'
								labelPosition='left'
								color='orange'
								size='large'
								onClick={this.handleCreate}
								content='Add Contest'
							/>
						</Form.Group>
					</Segment>
				</Container>
			</div>
		);
	}
}

export default NewContest;
