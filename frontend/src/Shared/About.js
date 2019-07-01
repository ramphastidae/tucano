import React from 'react';
import {Container, List, Segment} from 'semantic-ui-react';
import Pdf from "../resources/Cookies-Policy-Tucano.pdf";

class About extends React.Component {

	componentWillMount() {
		document.title = "Tucano - About";
	}


	render() {

		return (
			<React.Fragment>
				<Container className='tableContainer'>
					<Segment color='orange'>
						<h3>Developed By</h3>
						<List bulleted>
							<List.Item>
								Daniel Tinoco
							</List.Item>
							<List.Item>
								José Viana
							</List.Item>
							<List.Item>
								Miguel Magalhães
							</List.Item>
						</List>
						Find out more about the team and the project on <a
						href='https://github.com/ramphastidae'>Ramphastidae</a>

						<h3>Credits</h3>
						<a href="https://www.freepik.com/free-photos-vectors/nature">
							Logo
						</a> - Nature vector created by freepik - www.freepik.com
						<br/>
						<a href="https://www.freepik.com/free-photos-vectors/background">
							404 Error
						</a> - Background vector created by freepik - www.freepik.com

						<h3>Cookie Policy</h3>
						{/* eslint-disable-next-line react/jsx-no-target-blank */}
						<p>We use cookies and other tracking technologies to improve
							your browsing experience on our website, to show you
							personalized content and to analyze our website traffic.
							By browsing our website, you consent to our use of
							cookies and other tracking technologies.&nbsp;
							<a href={Pdf} target='_blank' rel='noopener noreferrer'>Cookie Policy</a>
						</p>

					</Segment>

				</Container>
			</React.Fragment>
		);
	}

}

export default About;
