import { Injectable, OnInit, OnDestroy } from '@angular/core';
import { Subject } from 'rxjs/Subject';
import { Observable } from 'rxjs';
import { HttpClient, HttpHeaders } from '@angular/common/http';

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

  debug: boolean = false;

  constructor(private http: HttpClient) {

    const port = this.getUrlParameter('port');

    if(port > 0) {
      this.port = port;
    }

    this.ajaxUrl = environment.host + this.port + '/' + environment.cf_dir;

    this.signUpValidated = this.getUrlParameter('signUpValidated');

    this.cfid = this.getUrlParameter('cfid');

    this.cftoken = this.getUrlParameter('cftoken');

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
    
  }

  
}
