import React, {Component} from 'react';
import {Grid, Image, Segment} from 'semantic-ui-react';
import logo from '../resources/tucano-baixo.png';
import './MyFooter.css';
import {Link} from "react-router-dom";

class MyFooter extends Component {

	render() {
		// noinspection HtmlUnknownTarget
		return (
			<Segment className='footer'>
				<Grid columns='equal' verticalAlign='middle'>
					<Grid.Column textAlign='center' width={6} >
						<Link to='/about'>About</Link>
					</Grid.Column>
					<Grid.Column textAlign='center' width={4} >
						<Image centered size='mini' src={logo}/>
					</Grid.Column>
					<Grid.Column textAlign='center' width={6} >
						Developed by <a href='https://github.com/ramphastidae'>Ramphastidae</a>
					</Grid.Column>
				</Grid>
			</Segment>
		);
	}
}

export default MyFooter
