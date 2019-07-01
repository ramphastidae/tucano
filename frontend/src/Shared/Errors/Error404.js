import React from 'react';
import {Container, Image} from 'semantic-ui-react';
import error from '../../resources/error404.svg';
import './Error.css';

class Error404 extends React.Component {
	render() {
		return (
			<React.Fragment>
				<Container className='tableContainer'>
					<Image className='image404' src={error}/>
				</Container>
			</React.Fragment>
		);
	}
}

export default Error404;
