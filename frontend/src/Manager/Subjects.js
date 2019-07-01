import React from 'react';
import ListItems from "../Shared/ListItems";

class Subjects extends React.Component {

	treatIncludedData(included, data) {

		for(let i=0; i<data.length; i++) {
			data[i].attributes['conflicts'] = "";

			for(let j=0; j<included.length; j++) {

				// settings
				if(included[j].type === "settings") {
					if(data[i].relationships.setting.data.id === included[j].id)
						data[i].attributes['setting'] = included[j].attributes.typeKey;
				}
				// conflicts
				if(included[j].type === "conflicts") {
					// eslint-disable-next-line array-callback-return
					data[i].relationships.conflicts.data.map(e => {
						if(e.id === included[j].id){
							let conflict;

							if(data[i].attributes.conflicts === "")
								conflict = included[j].attributes.subjectCode;
							else
								conflict = ', ' + included[j].attributes.subjectCode;

							data[i].attributes.conflicts = data[i].attributes.conflicts + conflict;
						}
					});
				}

			}
		}
		return data;
	}

	render() {
		return (
			<ListItems
				kind='Subject'
				api='/v1/subjects'
				add
				headers={{tenant: this.props.match.params.id}}
				fields={{
					code: 'Code',
					name: 'Name',
					setting: 'Subgroup',
					openings: 'Vacancies',
					conflicts: 'Conflicts'
				}}
				included={this.treatIncludedData}
				{...this.props}
			/>
		);
	}
}

export default Subjects;
