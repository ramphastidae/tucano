# Tucano - Generic Allocation Contest Manager


Web Application to manage allocation constests. Why is it **Generic**? Keep up with us for a little while.

### User types

* **Admin:** create **Managers** that will be responsible for contests.
* **Manager:** create contests and add **Applicants** to it.
* **Applicant:** Participates in severall contests.

### Creating a new Contest

When a Manager creates a new contest it can define its settings.

* What will participants be applying to (subgroups)
* How many are they applying to
* Period of the contest
* Other info

This gives the platform the flexibility to endure almost any kind of allocation contests.

### Adding Applicants and Subjects

After that the Manager can add applicants, and the subjects they will apply.

It can fill the correspondent form one by one or by uploading a `JSON`file with the following configurations:
	
* **Applicants**

```
{
	"users": [
		{
			"id": "s12345",
			"name": "John Doe",
			"email": "s12345@ramphastidae.tucano",
			"group": "Computer Science",
			"score": 12.345
		} 
	]
}
```

* **Subjects**

```
{
	"subjects": [
		{
			"id": "SUB1",
			"subgroup": "spec",
			"name": "Subject Number 1",
			"vacancies": 20,
			"schedule": [
				{
					"day": 1,
					"hourStart": "09:00",
					"hourEnd": "12:00"
				} 
			],
 			"conflicts": "SUB2, SUB5"
		}
	] 
}
```

### Editing Info

During the constest the manager can update severall info about each applicant and subject.

### Application

* **Problem Reporting:** Before the application period stars, applicants can report problems inside the platform for the contest manager.
* **Application:** During the defined contest period, applicants can perform their applications with a simple Drag and Drop according to their preferences, by subgroup.

### Post Application

When the application period ends, the manager can run the allocating algorithm and publish results for applicants.

Applicants can consult their results inside platform also.

The manager can export the results to a `csv` or `xls` file.

