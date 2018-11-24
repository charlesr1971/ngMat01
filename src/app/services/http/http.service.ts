import { Injectable, OnInit, OnDestroy } from '@angular/core';
import { Subject } from 'rxjs/Subject';
import { Observable, Subscription } from 'rxjs';
import { HttpClient, HttpHeaders } from '@angular/common/http';

import { User } from '../../user/user.model';
import { UserService } from '../../user/user.service';

import { CookieService } from 'ngx-cookie-service';

import { environment } from '../../../environments/environment';

@Injectable()
export class HttpService implements OnInit, OnDestroy { 
  
  port: string = '';
  signUpValidated: number = 0;
  cfid: number = 0;
  cftoken: string = '';
  ajaxUrl: string = '';
  subjectImagePath: Subject<any> = new Subject<any>();
  scrollCallbackData: Subject<any> = new Subject<any>();
  galleryPage: Subject<any> = new Subject<any>();
  userId: Subject<any> = new Subject<any>();
  userSubscription: Subscription;

  debug: boolean = false;

  constructor(private http: HttpClient,
    private userService: UserService,
    private cookieService: CookieService) {

    const port = this.getUrlParameter('port');
    if(port > 0) {
      this.port = port;
    }
    this.ajaxUrl = environment.host + this.port + '/' + environment.cf_dir;
    this.cfid = this.getUrlParameter('cfid');
    this.cftoken = this.getUrlParameter('cftoken');
    const body = {
      userToken: this.cookieService.get('userToken')
    };
    this.userSubscription = this.fetchUser(body).do(this.processUserData).subscribe();
    
  }

  ngOnInit() {
    
  }

  fetchSignUp(formData: any): Observable<any> {
    const body = {
      forename: formData['forename'],
      surname: formData['surname'],
      email: formData['email'],
      password: formData['password'],
      userToken: formData['userToken'],
      cfid: this.cfid,
      cftoken: this.cftoken
    };
    const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
    const headers = {
      headers: requestHeaders
    };
    return this.http.post(this.ajaxUrl + '/sign-up-datasource.cfm', body, headers);
  }

  private processUserData = (data) => {
    if(this.debug) {
      console.log('http.service: processUserData: data ',data);
    }
    const user: User = new User({
      userid: data['userid'],
      email: data['email'],
      salt: data['salt'],
      password: data['password'],
      forename: data['forename'],
      surname: data['surname'],
      userToken: data['userToken'],
      signUpToken: data['signUpToken'],
      signUpValidated: data['signUpValidated'],
      createdAt: data['createdat']
    });
    this.userService.setCurrentUser(user);
  }

  fetchUser(data: any): Observable<any> {
    const body = {
      userToken: data['userToken'],
    };
    const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
    const headers = {
      headers: requestHeaders
    };
    return this.http.post(this.ajaxUrl + '/user-datasource.cfm', body, headers);
  }

  fetchLogin(formData: any): Observable<any> {
    const body = {
      email: formData['email'],
      password: formData['password']
    };
    const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
    const headers = {
      headers: requestHeaders
    };
    return this.http.post(this.ajaxUrl + '/oauth-datasource.cfm', body, headers);
  }

  fetchDirectoryTree(): Observable<any> {
    return this.http.get(this.ajaxUrl + '/tree-dynamic-category-datasource.cfm');
  }

  fetchImages(page: number = 1): Observable<any> {
    return this.http.get(this.ajaxUrl + '/tree-dynamic-images-datasource.cfm?page=' + page);
  }

  fetchPages(): Observable<any> {
    return this.http.get(this.ajaxUrl + '/tree-dynamic-pages-datasource.cfm');
  }

  fetchLikes(id: any, add: any = 0, userToken: string = '', allowMultipleLikesPerUser: number = 0): Observable<any> {
    const body = {
      id: id,
      add: add,
      userToken: userToken,
      allowMultipleLikesPerUser: allowMultipleLikesPerUser
    };
    const requestHeaders = new HttpHeaders().set('Content-Type', 'application/json');
    const headers = {
      headers: requestHeaders
    };
    return this.http.post(this.ajaxUrl + '/tree-dynamic-likes-datasource.cfm', body, headers);
  }

  getUrlParameter(sParam): any {
    if(this.debug) {
      console.log('iframe src: ',decodeURIComponent(window.location.search.substring(1)));
    }
    return decodeURIComponent(window.location.search.substring(1)).split('&')
     .map((v) => { 
        return v.split('='); 
      })
     .filter((v) => { 
        return (v[0] === sParam) ? true : false; 
      })
     .reduce((acc:any,curr:any) => { 
        return curr[1]; 
      },0);
  };

  ngOnDestroy() {

    if (this.userSubscription) {
      this.userSubscription.unsubscribe();
    }

  }

  
}
