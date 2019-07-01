import React, {Component} from 'react';
import {Container, Dropdown, Image, Menu} from 'semantic-ui-react';
import logo from '../resources/tucano-cima.png';

class Header extends Component {
	constructor(props) {
		super(props);
		this.state = {
			value: null,
			user: null,
			width: window.innerWidth,
		};
		this.handleItemClick = this.handleItemClick.bind(this);
		this.handleWindowSizeChange = this.handleWindowSizeChange.bind(this);
	}

	componentWillMount() {
		window.addEventListener('resize', this.handleWindowSizeChange);
	}

	componentWillUnmount() {
		window.removeEventListener('resize', this.handleWindowSizeChange);
	}

	handleWindowSizeChange(event) {
		let el = event.target;
		this.setState({width: el.window.innerWidth});
	}

	handleItemClick(event, el) {
		if (el.name === '/logout') {
			localStorage.removeItem('token');
			localStorage.removeItem('usertype');
			localStorage.removeItem('userid');
			this.props.history.push('/');
			this.props.history.push('/login');
		} else {
			this.props.history.push(el.name);
		}

	}

	render() {
		const menu = {
			simple: [{
				key: 'about',
				name: '/about',
				content: 'About'
			}],
			admin: [{
				key: 'admin-managers',
				name: '/admin/managers',
				content: 'Managers'
			}],
			manager: [{
				key: 'my-contests',
				name: '/manager/contests',
				content: 'My Contests'
			}],
			user: [{
				key: 'my-contests',
				name: '/user/contests',
				content: 'My Contests'
			}],
			userContest: [{
				key: 'dashboard',
				name: '/user/contests/' + this.props.match.params.contest + '/dashboard',
				content: 'Dashboard'
			}, {
				key: 'application',
				name: '/user/contests/' + this.props.match.params.contest + '/application',
				content: 'Application'
			}, {
				key: 'results',
				name: '/user/contests/' + this.props.match.params.contest + '/results',
				content: 'Results'
			}, {
				key: 'my-contests',
				name: '/user/contests',
				content: 'Other Contests'
			}],
			managerContest: [{
				key: 'dashboard',
				name: '/manager/contests/' + this.props.match.params.contest + '/dashboard',
				content: 'Dashboard'
			}, {
				key: 'users',
				name: '/manager/contests/' + this.props.match.params.contest + '/users',
				content: 'Users'
			}, {
				key: 'subjects',
				name: '/manager/contests/' + this.props.match.params.contest + '/subjects',
				content: 'Subjects'
			}, {
				key: 'my-contests',
				name: '/manager/contests',
				content: 'Other Contests'
			}]
		};
		let options = menu[this.props.value];

		if (this.props.value !== 'simple') {
			options.push({
				key: 'logout',
				name: '/logout',
				content: '',
				icon: 'sign-out'
			})
		}

		if (this.state.width <= 1000) {
			return (
				<Menu fixed='top' size='massive' borderless>
					<Container>
						<Menu.Item
							name='/'
							onClick={this.handleItemClick}
							header
						>
							<Image size='small' src={logo}/>
						</Menu.Item>
						<Menu.Menu position='right' className='header'>
							<Dropdown item icon='bars'>
								<Dropdown.Menu>
									{options.map(option =>
										<Dropdown.Item
											key={option.key}
											onClick={this.handleItemClick}
											{...option}
										/>
									)}
								</Dropdown.Menu>
							</Dropdown>
						</Menu.Menu>
					</Container>
				</Menu>
			);
		} else {
			return (
				<Menu fixed='top' size='massive' borderless>
					<Container>
						<Menu.Item
							name='/'
							onClick={this.handleItemClick}
							header
						>
							<Image size='small' src={logo}/>
						</Menu.Item>
						<Menu.Menu position='right' className='header'>
							{options.map(option =>
								<Menu.Item
									key={option.key}
									onClick={this.handleItemClick}
									{...option}
								/>
							)}
						</Menu.Menu>
					</Container>
				</Menu>
			);
		}
	}
}

export default Header;
