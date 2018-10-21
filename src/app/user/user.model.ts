/**
 * A user represents an agent that uploads images
 */

export class User {

  userid: number;
  email: string;
  salt: string;
  password: string;
  forename: string;
  surname: string;
  userToken: string;
  signUpToken: string;
  createdAt: string;

  constructor(obj?: any) {

    this.userid = obj && obj.userid || 0;
    this.email = obj && obj.email || null;
    this.salt = obj && obj.salt || null;
    this.password = obj && obj.password || null;
    this.forename = obj && obj.forename || null;
    this.surname = obj && obj.surname || null;
    this.userToken = obj && obj.userToken || null;
    this.signUpToken = obj && obj.signUpToken || null;
    this.createdAt = obj && obj.createdAt || null;

  }
  
}
