# Canvas Integration

For this guide, we use `example.syllabustool.com` for the Salsa instance's hostname, and we use `example.instructure.com` for the Canvas Instance hostname. Replace these values with the correct values for your instances.

## Canvas Configuration

In the admin account, create an access key for an application

Admin -> Select account -> Developer Keys

    Key Name: Salsa (example.syllabustool.com)
    Owner Email: oasis4he@gmail.com
    Redirect URI (Legacy): http://example.syllabustool.com/oauth2/callback

Click Save Key

Take the `ID` and `Key` that are generated an put them in the config in Salsa

## Salsa Configuration

In Salsa, goto `example.syllabustool.com/admin` login, for each organization this is for:

Select organization -> Update Organization

    LMS Authentication Source: https://example.instructure.com
    LMS Client ID: ID
    LMS Authentication Key: Key

## Setup Users

### Get User ID from canvas

In Canvas, get the user ID for any users you want to allow to login to salsa (numeric ID that canvas uses is what is needed)

Admin -> Select Account -> People -> Search -> click on user record you are adding

The user ID we need is in the URL at the end (last verified 2017-11-10)

    https://example.instructure.com/accounts/{account_id}/users/{user_id}

For this example, our Account ID is 987654 and our user ID is 123456. We obtained that information from the URL when looking at the record in Canvas:

    https://example.instructure.com/accounts/987654/users/123456

### Add canvas user in Salsa

In salsa, visit `example.com/syllabustool.com/admin/users`

We are setting up an Organization Admin for this example (see Roles for details on what the different roles are for)

Click `Add User`, name and email are required, password won't matter if the only orgs you are adding access for have the canvas integration enabled (Salsa password logins are disabled for canvas orgs in Salsa, leaving this blank will disable password authentication and require use of their canvas account)

On the user details (click the user record /admin/users if editing later)

    LMS User ID: 123456
    Role: Organization Administrator
    Organization: Example Org (example.syllabustool.com)
    Cascades: yes

Click `Add Access`

## Testing

To test, logout (or use another session with your browser) and visit `example.syllabustool.com/admin` it should now redirect you to canvas to login. Login using canvas credentials (direct login is disabled for this instance)

It should now let you in as an organization admin (or whatever role was selected).

## Troubleshooting

If it redirects you back to Canvas or shows a login failure or permission denied error when you login through Canvas, you don't have permissions in Salsa. Double check the user ID entered and make sure it has been added for the organization you are trying to access the admin for in salsa.

If you are not logged in and it does not redirect to canvas when you visit /admin, check the LMS settings in the Organization Config from the `Salsa Configuration` in this guide.

### Developer Testing

If you have an instance of Salsa running, you can test the integration a few ways.

If you can add another developer key in the Canvas instance you are working with, add one specifying your local instance for the redirect URI (may not support `localhost`, `lvh.me` or a hostname of your choosing that points at your computer for you may work better with canvas)

If you can not add another developer key in Canvas, you can hack around it a few ways. Easiest is probably to set your hosts file on your OS to point to your instance using the hostname configured in salsa (be sure to run on port 80, or 443 if using https for the redirect URI in canvas). The thing to keep in mind is the redirect URI is client only, the servers don't care so long as the ID and Key match what they expect.
