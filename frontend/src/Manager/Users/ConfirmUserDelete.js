import React from 'react';
import ConfirmPage from "../../Shared/ConfirmPage";

class ConfirmUserDelete extends React.Component {
	render() {
		return (
			<ConfirmPage
				kind="delete all Users"
				api="/v1/applicants/all"
				method='delete'
				headers={{tenant: this.props.match.params.id}}
				{...this.props}
			/>
		);
	}
}

export default ConfirmUserDelete;
