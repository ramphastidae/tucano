import React from 'react';
import {Container, Image} from 'semantic-ui-react';
import error from '../../resources/error500.svg';
import './Error.css';

class Error5xx extends React.Component {
	render() {
		return (
			<React.Fragment>
				<Container className='tableContainer'>
					<Image className='image5xx' src={error}/>
				</Container>
			</React.Fragment>
		);
	}
}

export default Error5xx;
